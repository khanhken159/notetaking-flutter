import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notetaking_flutter/models/note.dart';
import 'package:notetaking_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    await storage.init();
  });

  group('StorageService Unit Tests', () {
    test('1. Initial seeding creates default notes and labels', () {
      final notes = storage.getActiveNotes();
      final labels = storage.getLabels();

      expect(notes.isNotEmpty, isTrue);
      expect(labels.isNotEmpty, isTrue);
      expect(labels.any((l) => l.name == 'Công việc'), isTrue);
      expect(labels.any((l) => l.name == 'Học tập'), isTrue);
    });

    test('2. Save and retrieve a new note', () async {
      final newNote = Note(
        id: 'test_note_1',
        title: 'Học tập Flutter Jetpack',
        content: 'So sánh Flutter và Jetpack Compose',
        isPinned: false,
        labelIds: ['lbl_work'],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await storage.saveNote(newNote);
      final retrieved = storage.getNoteById('test_note_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Học tập Flutter Jetpack');
      expect(retrieved.content, 'So sánh Flutter và Jetpack Compose');
      expect(retrieved.labelIds, contains('lbl_work'));
    });

    test('3. Edit an existing note', () async {
      final note = Note(
        id: 'test_note_edit',
        title: 'Tiêu đề cũ',
        content: 'Nội dung cũ',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(note);

      final updated = note.copyWith(
        title: 'Tiêu đề đã cập nhật',
        content: 'Nội dung mới',
        isPinned: true,
      );
      await storage.saveNote(updated);

      final retrieved = storage.getNoteById('test_note_edit');
      expect(retrieved!.title, 'Tiêu đề đã cập nhật');
      expect(retrieved.content, 'Nội dung mới');
      expect(retrieved.isPinned, isTrue);
    });

    test('4. Move note to trash and restore note', () async {
      final note = Note(
        id: 'trash_test_note',
        title: 'Ghi chú rác',
        content: 'Nội dung bỏ đi',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(note);

      // Move to trash
      await storage.moveNoteToTrash('trash_test_note');
      expect(storage.getActiveNotes().any((n) => n.id == 'trash_test_note'), isFalse);
      expect(storage.getTrashNotes().any((n) => n.id == 'trash_test_note'), isTrue);

      // Restore from trash
      await storage.restoreNoteFromTrash('trash_test_note');
      expect(storage.getActiveNotes().any((n) => n.id == 'trash_test_note'), isTrue);
      expect(storage.getTrashNotes().any((n) => n.id == 'trash_test_note'), isFalse);
    });

    test('5. Delete note permanently and empty trash', () async {
      final note1 = Note(
        id: 'perm_delete_1',
        title: 'Xóa vĩnh viễn 1',
        content: 'Test',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
      final note2 = Note(
        id: 'perm_delete_2',
        title: 'Xóa vĩnh viễn 2',
        content: 'Test',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
      await storage.saveNote(note1);
      await storage.saveNote(note2);

      await storage.deleteNotePermanently('perm_delete_1');
      expect(storage.getNoteById('perm_delete_1'), isNull);
      expect(storage.getNoteById('perm_delete_2'), isNotNull);

      await storage.emptyTrash();
      expect(storage.getTrashNotes().isEmpty, isTrue);
    });

    test('6. Search notes by title, content, and checklist item', () async {
      final note1 = Note(
        id: 'search_1',
        title: 'Họp chiến lược Quý 4',
        content: 'Bàn về kế hoạch kinh doanh',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = Note(
        id: 'search_2',
        title: 'Mua sắm gia đình',
        content: 'Siêu thị cuối tuần',
        isPinned: false,
        labelIds: [],
        checklist: [
          ChecklistItem(id: 'c1', text: 'Cà phê rang xay', isCompleted: false),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(note1);
      await storage.saveNote(note2);

      // Search by title
      final r1 = storage.searchAndFilter(query: 'chiến lược');
      expect(r1.any((n) => n.id == 'search_1'), isTrue);
      expect(r1.any((n) => n.id == 'search_2'), isFalse);

      // Search by content
      final r2 = storage.searchAndFilter(query: 'kinh doanh');
      expect(r2.any((n) => n.id == 'search_1'), isTrue);

      // Search by checklist item
      final r3 = storage.searchAndFilter(query: 'cà phê');
      expect(r3.any((n) => n.id == 'search_2'), isTrue);
    });

    test('7. Filter notes by label', () async {
      final note1 = Note(
        id: 'label_test_1',
        title: 'Ghi chú công việc',
        content: 'Nội dung',
        isPinned: false,
        labelIds: ['lbl_work'],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final note2 = Note(
        id: 'label_test_2',
        title: 'Ghi chú cá nhân',
        content: 'Nội dung',
        isPinned: false,
        labelIds: ['lbl_personal'],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(note1);
      await storage.saveNote(note2);

      final workNotes = storage.searchAndFilter(labelId: 'lbl_work');
      expect(workNotes.any((n) => n.id == 'label_test_1'), isTrue);
      expect(workNotes.any((n) => n.id == 'label_test_2'), isFalse);
    });

    test('8. Sort notes (updatedDesc, updatedAsc, titleAsc)', () async {
      final n1 = Note(
        id: 'sort_a',
        title: 'A Báo cáo doanh thu',
        content: '',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final n2 = Note(
        id: 'sort_b',
        title: 'B Kế hoạch nhân sự',
        content: '',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime(2026, 2, 1),
        updatedAt: DateTime(2026, 2, 1),
      );
      final n3 = Note(
        id: 'sort_c',
        title: 'C Tài liệu dự án',
        content: '',
        isPinned: false,
        labelIds: [],
        checklist: [],
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );

      // Clear all existing notes for clean sort testing
      for (final note in storage.getActiveNotes()) {
        await storage.deleteNotePermanently(note.id);
      }
      await storage.saveNote(n1);
      await storage.saveNote(n2);
      await storage.saveNote(n3);

      final byUpdatedDesc = storage.searchAndFilter(sortOption: SortOption.updatedDesc);
      expect(byUpdatedDesc.map((n) => n.id).toList(), ['sort_c', 'sort_b', 'sort_a']);

      final byUpdatedAsc = storage.searchAndFilter(sortOption: SortOption.updatedAsc);
      expect(byUpdatedAsc.map((n) => n.id).toList(), ['sort_a', 'sort_b', 'sort_c']);

      final byTitleAsc = storage.searchAndFilter(sortOption: SortOption.titleAsc);
      expect(byTitleAsc.map((n) => n.id).toList(), ['sort_a', 'sort_b', 'sort_c']);
    });

    test('9. Cascade untag when a label is deleted', () async {
      final testLabel = Label(id: 'lbl_cascade', name: 'Nhãn thử nghiệm', colorId: 'emerald');
      await storage.saveLabel(testLabel);

      final note = Note(
        id: 'cascade_note',
        title: 'Ghi chú có nhãn thử nghiệm',
        content: '',
        isPinned: false,
        labelIds: ['lbl_cascade', 'lbl_work'],
        checklist: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(note);

      expect(storage.getNoteById('cascade_note')!.labelIds, contains('lbl_cascade'));

      // Delete label
      await storage.deleteLabel('lbl_cascade');

      // Verify label removed from note, but note still exists and has remaining labels
      final updatedNote = storage.getNoteById('cascade_note');
      expect(updatedNote, isNotNull);
      expect(updatedNote!.labelIds.contains('lbl_cascade'), isFalse);
      expect(updatedNote.labelIds.contains('lbl_work'), isTrue);
    });

    test('10. Selective Note Lock and PIN verification', () async {
      expect(storage.hasPin, isFalse);

      // Set user PIN
      await storage.setLockPin('1234');
      expect(storage.hasPin, isTrue);
      expect(storage.verifyPin('1234'), isTrue);
      expect(storage.verifyPin('9999'), isFalse);

      // Create a locked note and an unlocked note
      final lockedNote = Note(
        id: 'locked_note_1',
        title: 'Bí mật kinh doanh',
        content: 'Nội dung tuyệt mật không được xem',
        isLocked: true,
      );
      final unlockedNote = Note(
        id: 'unlocked_note_1',
        title: 'Ghi chú công khai',
        content: 'Nội dung bình thường',
        isLocked: false,
      );

      await storage.saveNote(lockedNote);
      await storage.saveNote(unlockedNote);

      final retrievedLocked = storage.getNoteById('locked_note_1');
      expect(retrievedLocked, isNotNull);
      expect(retrievedLocked!.isLocked, isTrue);

      final retrievedUnlocked = storage.getNoteById('unlocked_note_1');
      expect(retrievedUnlocked, isNotNull);
      expect(retrievedUnlocked!.isLocked, isFalse);
    });

    test('11. Audio Memo recording and duration formatting', () async {
      final audioNote = Note(
        id: 'audio_note_1',
        title: 'Ghi chú cuộc họp có ghi âm',
        content: 'Đã thảo luận chiến lược Q4',
        audioDuration: 75, // 1 minute 15 seconds
        audioTitle: 'Ghi âm cuộc họp',
      );

      expect(audioNote.hasAudio, isTrue);
      expect(audioNote.audioDurationFormatted, equals('1:15'));

      await storage.saveNote(audioNote);

      final retrieved = storage.getNoteById('audio_note_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.hasAudio, isTrue);
      expect(retrieved.audioDuration, equals(75));
      expect(retrieved.audioTitle, equals('Ghi âm cuộc họp'));
    });
  });
}
