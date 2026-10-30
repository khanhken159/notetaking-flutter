import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/note_controller.dart';
import 'models/note.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/label_management_screen.dart';
import 'screens/trash_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LocalStorageService();
  final noteController = NoteController(storage: storageService);
  await noteController.init();

  runApp(NoteApp(controller: noteController));
}

class NoteApp extends StatelessWidget {
  final NoteController controller;

  const NoteApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghi chú',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      home: MainNavigationScreen(controller: controller),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final NoteController controller;

  const MainNavigationScreen({super.key, required this.controller});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  ActiveTab _currentTab = ActiveTab.notes;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final trashCount = widget.controller.trashNotes.length;

        return Scaffold(
          body: IndexedStack(
            index: _currentTab.index,
            children: [
              HomeScreen(controller: widget.controller),
              SearchScreen(controller: widget.controller),
              LabelManagementScreen(controller: widget.controller),
              TrashScreen(controller: widget.controller),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentTab: _currentTab,
            trashCount: trashCount,
            onTabSelected: (tab) {
              setState(() {
                _currentTab = tab;
              });
            },
          ),
        );
      },
    );
  }
}
