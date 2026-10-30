import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NoteController extends ChangeNotifier {
  final StorageService storage;

  NoteController({required this.storage});

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _selectedLabelId;
  String? get selectedLabelId => _selectedLabelId;

  SortOption _sortOption = SortOption.updatedDesc;
  SortOption get sortOption => _sortOption;

  ViewMode _viewMode = ViewMode.grid;
  ViewMode get viewMode => _viewMode;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Note> _activeNotes = [];
  List<Note> get activeNotes => List.unmodifiable(_activeNotes);

  List<Note> _trashNotes = [];
  List<Note> get trashNotes => List.unmodifiable(_trashNotes);

  List<Label> _labels = [];
  List<Label> get labels => List.unmodifiable(_labels);

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await storage.init();
    _refreshData();
    _isLoading = false;
    notifyListeners();
  }

  void _refreshData() {
    _labels = storage.getLabels();
    _trashNotes = storage.getTrashNotes();
    _activeNotes = storage.searchAndFilter(
      query: _searchQuery,
      labelId: _selectedLabelId,
      sortOption: _sortOption,
    );
  }

  List<Note> get pinnedNotes => _activeNotes.where((n) => n.isPinned).toList();
  List<Note> get otherNotes => _activeNotes.where((n) => !n.isPinned).toList();

  int getNoteCountForLabel(String labelId) {
    return storage.getActiveNotes().where((n) => n.labelIds.contains(labelId)).length;
  }

  void setSelectedLabel(String? labelId) {
    if (_selectedLabelId != labelId) {
      _selectedLabelId = labelId;
      _refreshData();
      notifyListeners();
    }
  }

  void setSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      _refreshData();
      notifyListeners();
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _refreshData();
    notifyListeners();
  }

  Future<void> saveNote(Note note) async {
    await storage.saveNote(note);
    _refreshData();
    notifyListeners();
  }

  Future<void> togglePin(String noteId) async {
    final note = storage.getNoteById(noteId);
    if (note != null) {
      final updated = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );
      await storage.saveNote(updated);
      _refreshData();
      notifyListeners();
    }
  }

  Future<void> moveNoteToTrash(String noteId) async {
    await storage.moveNoteToTrash(noteId);
    _refreshData();
    notifyListeners();
  }

  Future<void> restoreNote(String noteId) async {
    await storage.restoreNoteFromTrash(noteId);
    _refreshData();
    notifyListeners();
  }

  Future<void> deletePermanently(String noteId) async {
    await storage.deleteNotePermanently(noteId);
    _refreshData();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    await storage.emptyTrash();
    _refreshData();
    notifyListeners();
  }

  Future<void> createLabel(String name, String colorId) async {
    final newLabel = Label(
      id: 'lbl_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      colorId: colorId,
    );
    await storage.saveLabel(newLabel);
    _refreshData();
    notifyListeners();
  }

  Future<void> updateLabel(String id, String name, String colorId) async {
    final updated = Label(
      id: id,
      name: name.trim(),
      colorId: colorId,
    );
    await storage.updateLabel(updated);
    _refreshData();
    notifyListeners();
  }

  Future<void> deleteLabel(String id) async {
    if (_selectedLabelId == id) {
      _selectedLabelId = null;
    }
    await storage.deleteLabel(id);
    _refreshData();
    notifyListeners();
  }

  Label? getLabelById(String id) {
    try {
      return _labels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
