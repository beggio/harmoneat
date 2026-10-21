import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../../data/providers.dart';

enum RecorderStatus { idle, recording, stopped }

class AudioRecorderState {
  const AudioRecorderState({
    this.status = RecorderStatus.idle,
    this.filePath,
    this.errorMessage,
    this.elapsed = Duration.zero,
  });

  final RecorderStatus status;
  final String? filePath;
  final String? errorMessage;
  final Duration elapsed;

  AudioRecorderState copyWith({
    RecorderStatus? status,
    String? filePath,
    String? errorMessage,
    Duration? elapsed,
  }) {
    return AudioRecorderState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

/// Wraps `record` for capture. Writes straight into the attachments
/// directory with its final filename, so the caller only needs to register
/// the resulting path with [AttachmentsRepository] — no extra copy.
class AudioRecorderController extends Notifier<AudioRecorderState> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _elapsedTimer;
  DateTime? _startedAt;

  @override
  AudioRecorderState build() {
    ref.onDispose(() {
      _elapsedTimer?.cancel();
      _recorder.dispose();
    });
    return const AudioRecorderState();
  }

  Future<void> start() async {
    try {
      if (!await _recorder.hasPermission()) {
        state = state.copyWith(
          status: RecorderStatus.idle,
          errorMessage: 'Microphone permission was denied.',
        );
        return;
      }
      final dirs = ref.read(appDirectoriesProvider);
      final attachmentsDir = await dirs.attachmentsDirectory();
      final path = p.join(attachmentsDir.path, '${const Uuid().v4()}.wav');
      // WAV/PCM instead of the default AAC: AAC on Windows goes through a
      // Media Foundation encoder MFT that isn't guaranteed present on every
      // machine, which can silently produce a zero-length file. Raw PCM
      // capture has no such dependency.
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
      state = state.copyWith(
        status: RecorderStatus.recording,
        filePath: path,
        elapsed: Duration.zero,
      );

      _startedAt = DateTime.now();
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final startedAt = _startedAt;
        if (startedAt == null) return;
        state = state.copyWith(elapsed: DateTime.now().difference(startedAt));
      });
    } catch (e) {
      state = state.copyWith(
        status: RecorderStatus.idle,
        errorMessage: 'Could not start recording: $e',
      );
    }
  }

  Future<String?> stop() async {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _startedAt = null;
    try {
      final path = await _recorder.stop();
      if (path == null) {
        state = state.copyWith(
          status: RecorderStatus.idle,
          errorMessage: 'Recording stopped but produced no file.',
        );
        return null;
      }
      state = state.copyWith(status: RecorderStatus.stopped, filePath: path);
      return path;
    } catch (e) {
      state = state.copyWith(
        status: RecorderStatus.idle,
        errorMessage: 'Could not stop recording: $e',
      );
      return null;
    }
  }

  void reset() {
    state = const AudioRecorderState();
  }
}

final audioRecorderControllerProvider =
    NotifierProvider<AudioRecorderController, AudioRecorderState>(
      AudioRecorderController.new,
    );

/// Formats a duration as `MM:SS`, extending to `HH:MM:SS` once it reaches an
/// hour — used on the Stop button so recording progress is visible at a
/// glance.
String formatRecordingDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$mm:$ss';
  }
  return '$mm:$ss';
}
