import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../l10n/app_localizations.dart';

/// Free-text body editor for a note, autosaved after a short pause in
/// typing rather than on every keystroke.
class NoteBodyTab extends ConsumerStatefulWidget {
  const NoteBodyTab({
    super.key,
    required this.noteId,
    required this.initialBody,
  });

  final String noteId;
  final String? initialBody;

  @override
  ConsumerState<NoteBodyTab> createState() => _NoteBodyTabState();
}

class _NoteBodyTabState extends ConsumerState<NoteBodyTab> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(notesRepositoryProvider).updateBody(widget.noteId, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: l10n.noteBodyHint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
