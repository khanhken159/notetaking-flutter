import 'package:flutter/material.dart';

class ChecklistItem {
  final String id;
  String text;
  bool completed;

  ChecklistItem({
    required this.id,
    required this.text,
    bool? completed,
    bool? isCompleted,
  }) : completed = isCompleted ?? completed ?? false;

  bool get isCompleted => completed;
  set isCompleted(bool val) => completed = val;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'completed': completed,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
      );

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? completed,
    bool? isCompleted,
  }) =>
      ChecklistItem(
        id: id ?? this.id,
        text: text ?? this.text,
        completed: isCompleted ?? completed ?? this.completed,
      );
}

class Label {
  final String id;
  String name;
  String colorId;

  Label({
    required this.id,
    required this.name,
    required this.colorId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorId': colorId,
      };

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        colorId: json['colorId'] as String? ?? 'indigo',
      );

  Label copyWith({String? id, String? name, String? colorId}) => Label(
        id: id ?? this.id,
        name: name ?? this.name,
        colorId: colorId ?? this.colorId,
      );
}

class LabelColor {
  final String id;
  final String name;
  final String hex;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const LabelColor({
    required this.id,
    required this.name,
    required this.hex,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  Color get primary => primaryColor;
  Color get background => backgroundColor;
  Color get text => textColor;
  Color get border => borderColor;
}

class Note {
  final String id;
  String title;
  String content;
  bool isChecklist;
  List<ChecklistItem> checklist;
  List<String> labelIds;
  bool isPinned;
  bool isDeleted;
  final int createdAt;
  int updatedAt;
  int? deletedAt;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.isChecklist = false,
    List<ChecklistItem>? checklist,
    List<String>? labelIds,
    this.isPinned = false,
    this.isDeleted = false,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic deletedAt,
  })  : checklist = checklist ?? [],
        labelIds = labelIds ?? [],
        createdAt = _parseTimestamp(createdAt) ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = _parseTimestamp(updatedAt) ?? DateTime.now().millisecondsSinceEpoch,
        deletedAt = _parseTimestamp(deletedAt);

  static int? _parseTimestamp(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is DateTime) return val.millisecondsSinceEpoch;
    return null;
  }

  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedDateTime => DateTime.fromMillisecondsSinceEpoch(updatedAt);
  DateTime? get deletedDateTime => deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isChecklist': isChecklist,
        'checklist': checklist.map((e) => e.toJson()).toList(),
        'labelIds': labelIds,
        'isPinned': isPinned,
        'isDeleted': isDeleted,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'deletedAt': deletedAt,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        isChecklist: json['isChecklist'] as bool? ?? false,
        checklist: (json['checklist'] as List<dynamic>?)
                ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        labelIds: (json['labelIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isPinned: json['isPinned'] as bool? ?? false,
        isDeleted: json['isDeleted'] as bool? ?? false,
        createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: json['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        deletedAt: json['deletedAt'] as int?,
      );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isChecklist,
    List<ChecklistItem>? checklist,
    List<String>? labelIds,
    bool? isPinned,
    bool? isDeleted,
    dynamic createdAt,
    dynamic updatedAt,
    dynamic deletedAt,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        isChecklist: isChecklist ?? this.isChecklist,
        checklist: checklist ?? List.from(this.checklist),
        labelIds: labelIds ?? List.from(this.labelIds),
        isPinned: isPinned ?? this.isPinned,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt != null ? _parseTimestamp(createdAt) : this.createdAt,
        updatedAt: updatedAt != null ? _parseTimestamp(updatedAt) : this.updatedAt,
        deletedAt: deletedAt != null ? _parseTimestamp(deletedAt) : this.deletedAt,
      );
}

enum SortOption {
  updatedDesc('Mới cập nhật'),
  updatedAsc('Cũ nhất'),
  createdAsc('Cũ nhất'),
  titleAsc('Theo tên (A-Z)');

  final String displayName;
  const SortOption(this.displayName);
}

enum ViewMode { grid, list }

enum ActiveTab {
  notes('Ghi chú'),
  search('Tìm kiếm'),
  labels('Quản lý nhãn'),
  trash('Thùng rác');

  final String title;
  const ActiveTab(this.title);

  static ActiveTab get home => ActiveTab.notes;
}
