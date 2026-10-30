import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notetaking_flutter/controllers/note_controller.dart';
import 'package:notetaking_flutter/screens/note_editor_screen.dart';
import 'package:notetaking_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late NoteController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService();
    controller = NoteController(storage: storage);
    await controller.init();
  });

  testWidgets('NoteEditorScreen enters title, content and saves', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NoteEditorScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Find Title field and enter text
    final titleField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Tiêu đề',
    );
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Tiêu đề thử nghiệm');

    // Find Content field and enter text
    final contentField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Bắt đầu nhập nội dung ghi chú...',
    );
    expect(contentField, findsOneWidget);
    await tester.enterText(contentField, 'Nội dung chi tiết của ghi chú');

    // Wait for auto-save debounce
    await tester.pump(const Duration(milliseconds: 700));

    // Verify saved in controller / storage
    final notes = controller.storage.getActiveNotes();
    expect(notes.any((n) => n.title == 'Tiêu đề thử nghiệm'), isTrue);
  });

  testWidgets('NoteEditorScreen toggles checklist mode and adds item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NoteEditorScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Toggle checklist mode
    final checklistBtn = find.byIcon(Icons.check_box_outlined);
    expect(checklistBtn, findsOneWidget);
    await tester.tap(checklistBtn);
    await tester.pumpAndSettle();

    // Verify "Thêm mục mới" button is present
    expect(find.text('Thêm mục mới'), findsOneWidget);

    // Tap "Thêm mục mới"
    await tester.tap(find.text('Thêm mục mới'));
    await tester.pumpAndSettle();

    // Check that checkboxes are present
    expect(find.byType(Checkbox), findsAtLeastNWidgets(1));
  });
}
