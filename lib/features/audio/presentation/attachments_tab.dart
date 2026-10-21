import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/attachments_provider.dart';
import '../application/audio_playback_controller.dart';

class AttachmentsTab extends ConsumerWidget {
  const AttachmentsTab({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final attachmentsAsync = ref.watch(attachmentsProvider(noteId));

    return attachmentsAsync.when(
      data: (attachments) {
        if (attachments.isEmpty) {
          return Center(child: Text(l10n.attachmentsListEmpty));
        }
        return ListView.builder(
          itemCount: attachments.length,
          itemBuilder: (context, index) =>
              _AttachmentListItem(attachment: attachments[index]),
        );
      },
      error: (error, stack) => Center(child: Text('$error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AttachmentListItem extends ConsumerStatefulWidget {
  const _AttachmentListItem({required this.attachment});

  final Attachment attachment;

  @override
  ConsumerState<_AttachmentListItem> createState() =>
      _AttachmentListItemState();
}

class _AttachmentListItemState extends ConsumerState<_AttachmentListItem> {
  @override
  void initState() {
    super.initState();
    // Fetch real duration up front — otherwise every unplayed attachment
    // shows a bare "0:00", which looks exactly like an empty recording.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final absolutePath = await ref
          .read(attachmentsRepositoryProvider)
          .absolutePath(widget.attachment);
      if (!mounted) return;
      await ref
          .read(audioPlaybackControllerProvider(widget.attachment.id).notifier)
          .preload(absolutePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final playbackState = ref.watch(
      audioPlaybackControllerProvider(widget.attachment.id),
    );

    return ListTile(
      leading: IconButton(
        icon: Icon(
          playbackState.status == PlaybackStatus.playing
              ? Icons.pause_circle
              : Icons.play_circle,
        ),
        onPressed: () => _togglePlayback(playbackState),
      ),
      title: Text(widget.attachment.originalFileName ?? widget.attachment.id),
      subtitle: Text(
        _formatDuration(playbackState.position, playbackState.duration),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l10n.deleteAttachment,
        onPressed: () =>
            ref.read(attachmentsRepositoryProvider).delete(widget.attachment),
      ),
    );
  }

  Future<void> _togglePlayback(AudioPlaybackState playbackState) async {
    final controller = ref.read(
      audioPlaybackControllerProvider(widget.attachment.id).notifier,
    );
    switch (playbackState.status) {
      case PlaybackStatus.playing:
        await controller.pause();
      case PlaybackStatus.paused:
        await controller.resume();
      default:
        final absolutePath = await ref
            .read(attachmentsRepositoryProvider)
            .absolutePath(widget.attachment);
        await controller.loadAndPlay(absolutePath);
    }
  }

  String _formatDuration(Duration position, Duration? duration) {
    String fmt(Duration d) =>
        '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    if (duration == null) return 'Loading…';
    return '${fmt(position)} / ${fmt(duration)}';
  }
}
