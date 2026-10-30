import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notetaking_flutter/main.dart';
import 'package:notetaking_flutter/controllers/note_controller.dart';
import 'package:notetaking_flutter/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete end-to-end flow: create, persist, search, filter, trash, restore', (tester) async {
    // Phase 1: Launch App with initial clean mock storage
    SharedPreferences.setMockInitialValues({});
    final storageService = LocalStorageService();
    final controller = NoteController(storage: storageService);
    await controller.init();

    await tester.pumpWidget(NoteApp(controller: controller));
    await tester.pumpAndSettle();

    // Verify initial home screen loaded
    expect(find.text('Ghi chú'), findsAtLeastNWidgets(1));

    // Phase 2: Create a new note
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Type title and content
    final titleInput = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Tiêu đề',
    );
    await tester.enterText(titleInput, 'Kế hoạch công tác TP.HCM');

    final contentInput = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Bắt đầu nhập nội dung ghi chú...',
    );
    await tester.enterText(contentInput, 'Gặp đối tác chiến lược và ký hợp đồng');

    // Pin the note
    final pinButton = find.byTooltip('Ghim ghi chú');
    expect(pinButton, findsOneWidget);
    await tester.tap(pinButton);
    await tester.pumpAndSettle();

    // Back to home
    final backBtn = find.byTooltip('Trở về và lưu ghi chú');
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify the new note appears in Pinned section on Home screen
    expect(find.text('Kế hoạch công tác TP.HCM'), findsOneWidget);

    // Phase 3: Simulate closing and reopening app (persistence check)
    // Instantiate new storage and controller referencing the same underlying storage
    final reopenedStorage = LocalStorageService();
    final reopenedController = NoteController(storage: reopenedStorage);
    await reopenedController.init();

    await tester.pumpWidget(NoteApp(controller: reopenedController));
    await tester.pumpAndSettle();

    // Verify data persisted after app restart
    expect(find.text('Kế hoạch công tác TP.HCM'), findsOneWidget);

    // Phase 4: Test Search Tab
    // Switch to Search tab
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Enter search query in SearchScreen's search input
    final searchInput = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Tìm kiếm theo tiêu đề, nội dung...',
    );
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'đối tác');
    await tester.pumpAndSettle();

    // Verify search finds our note
    expect(find.text('Kế hoạch công tác TP.HCM'), findsOneWidget);

    // Phase 5: Move note to trash
    // Open the note
    await tester.tap(find.text('Kế hoạch công tác TP.HCM'));
    await tester.pumpAndSettle();

    // Tap delete button in editor
    final deleteBtn = find.byTooltip('Chuyển vào thùng rác');
    expect(deleteBtn, findsOneWidget);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Confirm dialog
    final confirmDeleteBtn = find.text('Xóa');
    expect(confirmDeleteBtn, findsOneWidget);
    await tester.tap(confirmDeleteBtn);
    await tester.pumpAndSettle();

    // Note should no longer be in active list
    expect(find.text('Kế hoạch công tác TP.HCM'), findsNothing);

    // Phase 6: Switch to Trash tab and restore
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Verify note is in Trash
    expect(find.text('Kế hoạch công tác TP.HCM'), findsOneWidget);

    // Tap "Khôi phục"
    final restoreBtn = find.text('Khôi phục').first;
    await tester.tap(restoreBtn);
    await tester.pumpAndSettle();

    // Verify it is restored in controller
    expect(controller.activeNotes.any((n) => n.title == 'Kế hoạch công tác TP.HCM'), isTrue);

    // Switch back to "Ghi chú" tab using bottom navigation icon
    await tester.tap(find.byIcon(Icons.note_alt_outlined));
    await tester.pumpAndSettle();

    // Scroll until visible if needed
    await tester.scrollUntilVisible(
      find.text('Kế hoạch công tác TP.HCM'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kế hoạch công tác TP.HCM'), findsOneWidget);
  });
}
