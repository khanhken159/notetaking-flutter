import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notetaking_flutter/controllers/note_controller.dart';
import 'package:notetaking_flutter/screens/home_screen.dart';
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

  testWidgets('HomeScreen renders title, filter chips, and pinned notes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title
    expect(find.text('Ghi chú'), findsOneWidget);

    // Verify "Tất cả" filter chip exists
    expect(find.textContaining('Tất cả'), findsOneWidget);

    // Verify pinned section header
    expect(find.text('ĐÃ GHIM'), findsOneWidget);

    // Verify FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('HomeScreen toggle view mode and sort menu', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Tap view mode button
    final viewModeBtn = find.byIcon(Icons.view_agenda_outlined);
    expect(viewModeBtn, findsOneWidget);
    await tester.tap(viewModeBtn);
    await tester.pumpAndSettle();

    // Now icon should be grid_view_outlined
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);

    // Open sort menu
    final sortBtn = find.byIcon(Icons.sort);
    expect(sortBtn, findsOneWidget);
    await tester.tap(sortBtn);
    await tester.pumpAndSettle();

    // Verify menu items
    expect(find.text('Mới cập nhật'), findsOneWidget);
    expect(find.text('Cũ nhất'), findsOneWidget);
    expect(find.text('Theo tên (A-Z)'), findsOneWidget);
  });
}
