import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves absolute, per-platform storage locations and converts between
/// the relative paths stored in the database and absolute filesystem paths.
///
/// This is the single seam wrapping `path_provider` so the rest of the app
/// never depends on its platform-specific quirks directly.
class AppDirectories {
  const AppDirectories();

  Future<Directory> documentsDirectory() => getApplicationDocumentsDirectory();

  Future<Directory> supportDirectory() => getApplicationSupportDirectory();

  Future<Directory> attachmentsDirectory() async {
    final docs = await documentsDirectory();
    final dir = Directory(p.join(docs.path, 'attachments'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Converts a relative path (as stored in the database) to an absolute
  /// path under the documents directory.
  Future<String> resolve(String relativePath) async {
    final docs = await documentsDirectory();
    return p.join(docs.path, relativePath);
  }

  /// Converts an absolute path under the documents directory back to the
  /// relative form that should be stored in the database.
  Future<String> relativize(String absolutePath) async {
    final docs = await documentsDirectory();
    return p.relative(absolutePath, from: docs.path);
  }

  /// Name of the cloud-sync provider whose folder the resolved documents
  /// directory sits inside (where recordings and imported audio land), e.g.
  /// `C:\Users\<user>\OneDrive\Documents` instead of the raw profile
  /// Documents folder — or `null` if it looks like a plain local folder.
  /// Detected by well-known folder-name segments rather than a provider
  /// API, since there's no cross-platform way to ask "is this synced"
  /// directly.
  Future<String?> detectCloudSyncProvider() async {
    final docs = await documentsDirectory();
    final segments = p.split(docs.path);
    for (final segment in segments) {
      if (segment == 'OneDrive' || segment.startsWith('OneDrive - ')) {
        return 'OneDrive';
      }
      if (segment == 'Dropbox') return 'Dropbox';
      if (segment == 'Mobile Documents' ||
          segment.contains('com~apple~CloudDocs')) {
        return 'iCloud Drive';
      }
    }
    return null;
  }
}
