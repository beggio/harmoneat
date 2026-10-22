import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmoneat/app/app.dart';
import 'package:harmoneat/app/app_version_provider.dart';
import 'package:harmoneat/data/database/database.dart';
import 'package:harmoneat/data/providers.dart';
import 'package:harmoneat/data/repositories/attachments_repository.dart';
import 'package:harmoneat/data/repositories/notes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Stubs the Attachments tab's data source so mounting the pushed note
/// detail screen never touches a real database (which would need
/// `path_provider`'s platform channel — unavailable in a widget test).
class _FakeAttachmentsRepository implements AttachmentsRepository {
  @override
  Stream<List<Attachment>> watchForNote(String noteId) {
    return Stream.multi((controller) => controller.add(const []));
  }

  @override
  Future<Attachment> registerFile({
    required String noteId,
    required String absolutePath,
    required AttachmentSource source,
    String? originalFileName,
    int? durationMs,
  }) => throw UnimplementedError();

  @override
  Future<Attachment> importFile({
    required String noteId,
    required File sourceFile,
  }) => throw UnimplementedError();

  @override
  Future<String> absolutePath(Attachment attachment) =>
      throw UnimplementedError();

  @override
  Future<void> delete(Attachment attachment) => throw UnimplementedError();
}

/// An in-memory fake — deliberately avoids a real Drift database in this
/// widget test. A real `NativeDatabase` stream query left a pending Timer
/// behind under `AutomatedTestWidgetsFlutterBinding`'s strict teardown
/// check; the data layer itself is covered against a real database in
/// test/data/notes_repository_test.dart instead.
class _FakeNotesRepository implements NotesRepository {
  final _notes = <Note>[];
  final _controller = StreamController<List<Note>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_notes));

  @override
  Stream<List<Note>> watchAll() {
    // Each subscriber gets the current snapshot immediately, then updates —
    // a plain broadcast stream drops emissions made before a late
    // subscriber (e.g. the pushed detail screen) attaches.
    return Stream.multi((controller) {
      controller.add(List.unmodifiable(_notes));
      final sub = _controller.stream.listen(controller.add);
      controller.onCancel = sub.cancel;
    });
  }

  @override
  Stream<Note?> watchById(String id) {
    return watchAll().map(
      (notes) => notes.where((n) => n.id == id).firstOrNull,
    );
  }

  @override
  Future<String> create({String title = ''}) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      body: null,
      createdAt: now,
      updatedAt: now,
    );
    _notes.add(note);
    _emit();
    return note.id;
  }

  @override
  Future<void> rename(String id, String title) async {
    final index = _notes.indexWhere((n) => n.id == id);
    _notes[index] = _notes[index].copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
    _emit();
  }

  @override
  Future<void> updateBody(String id, String body) async {
    final index = _notes.indexWhere((n) => n.id == id);
    _notes[index] = _notes[index].copyWith(
      body: Value(body.isEmpty ? null : body),
      updatedAt: DateTime.now(),
    );
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _emit();
  }
}

void main() {
  testWidgets('create a note from the notes list, see it appear', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final fakeRepo = _FakeNotesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesRepositoryProvider.overrideWithValue(fakeRepo),
          attachmentsRepositoryProvider.overrideWithValue(
            _FakeAttachmentsRepository(),
          ),
          // Avoids package_info_plus's platform channel, which has no
          // response in a widget test.
          appVersionProvider.overrideWith((ref) => '1.0.0+1'),
        ],
        child: const HarmoNeatApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The splash screen is in front of everything on a version that
    // hasn't been seen before (which, in a fresh test, is every time).
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet. Tap + to create one.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Untitled note'), findsOneWidget);
  });
}
