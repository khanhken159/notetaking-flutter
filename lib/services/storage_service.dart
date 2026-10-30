import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../models/initial_data.dart';

abstract class StorageService {
  Future<void> init();
  List<Note> getActiveNotes();
  List<Note> getTrashNotes();
  List<Label> getLabels();
  Note? getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> moveNoteToTrash(String id);
  Future<void> restoreNoteFromTrash(String id);
  Future<void> deleteNotePermanently(String id);
  Future<void> emptyTrash();
  Future<void> saveLabel(Label label);
  Future<void> updateLabel(Label label);
  Future<void> deleteLabel(String id);
  List<Note> searchAndFilter({
    String query = '',
    String? labelId,
    SortOption sortOption = SortOption.updatedDesc,
  });

  // Selective Note Lock PIN management
  String? getLockPin();
  Future<void> setLockPin(String pin);
  bool verifyPin(String pin);
  bool get hasPin;
}

class LocalStorageService implements StorageService {
  static const String _notesKey = 'notes_data_v1';
  static const String _labelsKey = 'labels_data_v1';
  static const String _pinKey = 'user_lock_pin_v1';

  final SharedPreferences? _prefsInstance;
  late SharedPreferences _prefs;

  final List<Note> _notes = [];
  final List<Label> _labels = [];
  String? _lockPin;

  LocalStorageService([this._prefsInstance]);

  @override
  Future<void> init() async {
    _prefs = _prefsInstance ?? await SharedPreferences.getInstance();

    _lockPin = _prefs.getString(_pinKey);

    final labelsJson = _prefs.getString(_labelsKey);
    if (labelsJson != null && labelsJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(labelsJson) as List<dynamic>;
        _labels.clear();
        _labels.addAll(list.map((e) => Label.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        _seedDefaultLabels();
      }
    } else {
      _seedDefaultLabels();
    }

    final notesJson = _prefs.getString(_notesKey);
    if (notesJson != null && notesJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(notesJson) as List<dynamic>;
        _notes.clear();
        _notes.addAll(list.map((e) => Note.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        _seedDefaultNotes();
      }
    } else {
      _seedDefaultNotes();
    }
  }

  @override
  String? getLockPin() => _lockPin;

  @override
  bool get hasPin => _lockPin != null && _lockPin!.isNotEmpty;

  @override
  Future<void> setLockPin(String pin) async {
    _lockPin = pin;
    await _prefs.setString(_pinKey, pin);
  }

  @override
  bool verifyPin(String pin) {
    if (_lockPin == null || _lockPin!.isEmpty) return false;
    return _lockPin == pin;
  }

  void _seedDefaultLabels() {
    _labels.clear();
    _labels.addAll(initialLabels);
    _saveLabels();
  }

  void _seedDefaultNotes() {
    _notes.clear();
    _notes.addAll(getInitialNotes());
    _saveNotes();
  }

  Future<void> _saveNotes() async {
    final jsonStr = jsonEncode(_notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_notesKey, jsonStr);
  }

  Future<void> _saveLabels() async {
    final jsonStr = jsonEncode(_labels.map((e) => e.toJson()).toList());
    await _prefs.setString(_labelsKey, jsonStr);
  }

  @override
  List<Note> getActiveNotes() {
    return _notes.where((n) => !n.isDeleted).toList();
  }

  @override
  List<Note> getTrashNotes() {
    return _notes.where((n) => n.isDeleted).toList();
  }

  @override
  List<Label> getLabels() {
    return List.unmodifiable(_labels);
  }

  @override
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.insert(0, note);
    }
    await _saveNotes();
  }

  @override
  Future<void> moveNoteToTrash(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(
        isDeleted: true,
        deletedAt: DateTime.now().millisecondsSinceEpoch,
        isPinned: false,
      );
      await _saveNotes();
    }
  }

  @override
  Future<void> restoreNoteFromTrash(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(
        isDeleted: false,
        deletedAt: null,
      );
      await _saveNotes();
    }
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }

  @override
  Future<void> emptyTrash() async {
    _notes.removeWhere((n) => n.isDeleted);
    await _saveNotes();
  }

  @override
  Future<void> saveLabel(Label label) async {
    _labels.add(label);
    await _saveLabels();
  }

  @override
  Future<void> updateLabel(Label label) async {
    final index = _labels.indexWhere((l) => l.id == label.id);
    if (index >= 0) {
      _labels[index] = label;
      await _saveLabels();
    }
  }

  @override
  Future<void> deleteLabel(String id) async {
    _labels.removeWhere((l) => l.id == id);
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].labelIds.contains(id)) {
        final newLabels = List<String>.from(_notes[i].labelIds)..remove(id);
        _notes[i] = _notes[i].copyWith(labelIds: newLabels);
      }
    }
    await _saveLabels();
    await _saveNotes();
  }

  @override
  List<Note> searchAndFilter({
    String query = '',
    String? labelId,
    SortOption sortOption = SortOption.updatedDesc,
  }) {
    var result = getActiveNotes();

    // Label filter
    if (labelId != null && labelId.isNotEmpty) {
      result = result.where((n) => n.labelIds.contains(labelId)).toList();
    }

    // Text search
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((n) {
        final titleMatch = n.title.toLowerCase().contains(q);
        final contentMatch = n.content.toLowerCase().contains(q);
        final checklistMatch = n.checklist.any((item) => item.text.toLowerCase().contains(q));
        return titleMatch || contentMatch || checklistMatch;
      }).toList();
    }

    // Sorting
    result.sort((a, b) {
      switch (sortOption) {
        case SortOption.updatedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case SortOption.updatedAsc:
        case SortOption.createdAsc:
          return a.updatedAt.compareTo(b.updatedAt);
        case SortOption.titleAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return result;
  }
}
