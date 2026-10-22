# Builds a beta-test package: a release Windows build with the beta
# feedback/crash-reporting/usage-tracking system compiled in (see
# lib/beta/beta_config.dart), zipped up ready to send to testers.
#
# Reads the webhook URL from beta.local.json (gitignored — never commit
# it) at the repo root. Copy beta.local.json.example to beta.local.json
# and fill in your webhook URL before running this for the first time.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "beta.local.json"

if (-not (Test-Path $configPath)) {
    Write-Error "beta.local.json not found at $configPath. Copy beta.local.json.example to beta.local.json and fill in your webhook URL first."
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$webhookUrl = $config.webhookUrl
if ([string]::IsNullOrWhiteSpace($webhookUrl) -or $webhookUrl -like "*REPLACE_WITH*") {
    Write-Error "beta.local.json's webhookUrl looks unset. Fill in your actual webhook URL."
    exit 1
}

Push-Location $repoRoot
try {
    Write-Host "Building beta Windows release..."
    & flutter build windows --release `
        --dart-define=BETA_BUILD=true `
        --dart-define="FEEDBACK_WEBHOOK_URL=$webhookUrl"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter build windows failed."
        exit $LASTEXITCODE
    }

    $releaseDir = Join-Path $repoRoot "build\windows\x64\runner\Release"
    if (-not (Test-Path $releaseDir)) {
        Write-Error "Expected release output not found at $releaseDir."
        exit 1
    }

    $distDir = Join-Path $repoRoot "dist"
    New-Item -ItemType Directory -Force -Path $distDir | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $zipPath = Join-Path $distDir "harmoneat-beta-$timestamp.zip"

    # Stage in a temp folder rather than zipping Release in place, so the
    # bundled README doesn't end up sitting in the Flutter build output
    # directory itself.
    $stagingDir = Join-Path $distDir "staging-$timestamp"
    New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null
    Copy-Item -Path (Join-Path $releaseDir "*") -Destination $stagingDir -Recurse
    Copy-Item -Path (Join-Path $repoRoot "TESTER_README.md") -Destination (Join-Path $stagingDir "README.md")

    Write-Host "Zipping $stagingDir -> $zipPath"
    Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $zipPath -Force
    Remove-Item -Path $stagingDir -Recurse -Force

    Write-Host "Done: $zipPath"
}
finally {
    Pop-Location
}
