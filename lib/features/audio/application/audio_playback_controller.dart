import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum PlaybackStatus { idle, loading, playing, paused, completed }

class AudioPlaybackState {
  const AudioPlaybackState({
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration,
  });

  final PlaybackStatus status;
  final Duration position;
  final Duration? duration;

  AudioPlaybackState copyWith({
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlaybackState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Family keyed by attachmentId — wraps a `just_audio` player; disposing
/// with the provider matters on desktop, where `just_audio_media_kit` holds
/// native handles.
///
/// Riverpod 3 passes a family's argument to the create callback, not to
/// `build()` — so the id is a constructor field, not a `build` parameter.
class AudioPlaybackController extends Notifier<AudioPlaybackState> {
  AudioPlaybackController(this.attachmentId);

  final String attachmentId;
  late final AudioPlayer _player;
  bool _playbackRequested = false;

  @override
  AudioPlaybackState build() {
    _player = AudioPlayer();
    _player.playerStateStream.listen((playerState) {
      final duration = _player.duration;
      if (!_playbackRequested) {
        // A preload-only load (metadata fetched so duration can display) —
        // don't claim a playing/paused state the user never asked for.
        state = state.copyWith(duration: duration);
        return;
      }
      final status = switch (playerState.processingState) {
        ProcessingState.completed => PlaybackStatus.completed,
        ProcessingState.loading ||
        ProcessingState.buffering => PlaybackStatus.loading,
        _ =>
          playerState.playing ? PlaybackStatus.playing : PlaybackStatus.paused,
      };
      state = state.copyWith(status: status, duration: duration);
    });
    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    ref.onDispose(_player.dispose);
    return const AudioPlaybackState();
  }

  /// Loads file metadata (so the real duration can be shown) without
  /// starting playback. Safe to call repeatedly — a no-op once a duration
  /// is already known or playback has been requested.
  Future<void> preload(String absolutePath) async {
    if (state.duration != null || _playbackRequested) return;
    await _player.setFilePath(absolutePath);
  }

  Future<void> loadAndPlay(String absolutePath) async {
    _playbackRequested = true;
    await _player.setFilePath(absolutePath);
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() {
    _playbackRequested = true;
    return _player.play();
  }

  Future<void> seek(Duration position) => _player.seek(position);
}

final audioPlaybackControllerProvider =
    NotifierProvider.family<
      AudioPlaybackController,
      AudioPlaybackState,
      String
    >((attachmentId) => AudioPlaybackController(attachmentId));
