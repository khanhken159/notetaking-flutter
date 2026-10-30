import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteController controller;
  final Note? note;

  const NoteEditorScreen({
    super.key,
    required this.controller,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late String _noteId;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isPinned;
  late List<String> _labelIds;
  late List<ChecklistItem> _checklist;
  late bool _isChecklistMode;
  late int _createdAt;

  Timer? _debounceTimer;
  bool _isSaving = false;
  String _saveStatus = 'Đã lưu';
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    if (n != null) {
      _noteId = n.id;
      _titleController = TextEditingController(text: n.title);
      _contentController = TextEditingController(text: n.content);
      _isPinned = n.isPinned;
      _labelIds = List<String>.from(n.labelIds);
      _checklist = n.checklist.map((c) => c.copyWith()).toList();
      _isChecklistMode = n.checklist.isNotEmpty;
      _createdAt = n.createdAt;
    } else {
      _noteId = 'note_${DateTime.now().millisecondsSinceEpoch}';
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _isPinned = false;
      _labelIds = [];
      _checklist = [];
      _isChecklistMode = false;
      _createdAt = DateTime.now().millisecondsSinceEpoch;
    }

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _saveStatus = 'Đang lưu...';
      _isSaving = true;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    if (_isDeleted) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If everything is completely empty, don't persist an empty note
    if (title.isEmpty && content.isEmpty && _checklist.isEmpty) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveStatus = 'Trống';
        });
      }
      return;
    }

    final note = Note(
      id: _noteId,
      title: _titleController.text,
      content: _contentController.text,
      isPinned: _isPinned,
      labelIds: _labelIds,
      checklist: _checklist,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
      isDeleted: false,
    );

    await widget.controller.saveNote(note);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _saveStatus = 'Đã lưu lúc ${_formatCurrentTime()}';
      });
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    _autoSave();
  }

  void _toggleChecklistMode() {
    setState(() {
      _isChecklistMode = !_isChecklistMode;
      if (_isChecklistMode && _checklist.isEmpty) {
        // If content has lines, convert to checklist items
        final lines = _contentController.text.split('\n').where((l) => l.trim().isNotEmpty);
        if (lines.isNotEmpty) {
          _checklist = lines.map((l) => ChecklistItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}_${l.hashCode}',
            text: l.trim(),
            isCompleted: false,
          )).toList();
        } else {
          _checklist.add(ChecklistItem(
            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
            text: '',
            isCompleted: false,
          ));
        }
      }
    });
    _autoSave();
  }

  void _addChecklistItem() {
    setState(() {
      _checklist.add(ChecklistItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        text: '',
        isCompleted: false,
      ));
    });
    _autoSave();
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chuyển vào thùng rác?'),
        content: const Text('Ghi chú này sẽ được chuyển vào thùng rác. Bạn có thể khôi phục lại sau.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _isDeleted = true;
              _debounceTimer?.cancel();
              Navigator.of(ctx).pop();
              widget.controller.moveNoteToTrash(_noteId);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLabelSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final allLabels = widget.controller.labels;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chọn nhãn cho ghi chú',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (allLabels.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Chưa có nhãn nào. Hãy tạo nhãn trong mục Quản lý nhãn.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ...allLabels.map((lbl) {
                        final isChecked = _labelIds.contains(lbl.id);
                        final color = getLabelColor(lbl.colorId);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(lbl.name),
                            ],
                          ),
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setSheetState(() {
                              if (val == true) {
                                _labelIds.add(lbl.id);
                              } else {
                                _labelIds.remove(lbl.id);
                              }
                            });
                            setState(() {});
                            _autoSave();
                          },
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteLabels = widget.controller.labels
        .where((l) => _labelIds.contains(l.id))
        .toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _autoSave();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Trở về và lưu ghi chú',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await _autoSave();
              if (!mounted) return;
              navigator.pop();
            },
          ),
          title: Text(
            _saveStatus,
            style: TextStyle(
              fontSize: 12,
              color: _isSaving ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            // Checklist Mode Toggle
            IconButton(
              icon: Icon(
                _isChecklistMode ? Icons.check_box : Icons.check_box_outlined,
                color: _isChecklistMode ? AppColors.primary : AppColors.textSecondary,
              ),
              tooltip: _isChecklistMode ? 'Chuyển sang văn bản thường' : 'Tạo danh sách công việc',
              onPressed: _toggleChecklistMode,
            ),

            // Label Selector
            IconButton(
              icon: const Icon(Icons.label_outline, color: AppColors.textSecondary),
              tooltip: 'Gắn nhãn',
              onPressed: _showLabelSelector,
            ),

            // Pin / Unpin
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.primary : AppColors.textSecondary,
              ),
              tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim ghi chú',
              onPressed: _togglePin,
            ),

            // Delete
            if (widget.note != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Chuyển vào thùng rác',
                onPressed: _deleteNote,
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Selected Labels Chips
              if (noteLabels.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: noteLabels.map((lbl) {
                      final c = getLabelColor(lbl.colorId);
                      return Chip(
                        label: Text(
                          lbl.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.primary,
                          ),
                        ),
                        backgroundColor: c.background,
                        side: BorderSide(color: c.border),
                        deleteIcon: Icon(Icons.close, size: 14, color: c.primary),
                        onDeleted: () {
                          setState(() {
                            _labelIds.remove(lbl.id);
                          });
                          _autoSave();
                        },
                      );
                    }).toList(),
                  ),
                ),

              // Title and Body Input Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title TextField
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tiêu đề',
                          hintStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Content or Checklist
                      if (_isChecklistMode)
                        _buildChecklistEditor()
                      else
                        TextField(
                          controller: _contentController,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Bắt đầu nhập nội dung ghi chú...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_checklist.length, (index) {
          final item = _checklist[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  label: item.isCompleted ? 'Đánh dấu chưa hoàn thành' : 'Đánh dấu đã hoàn thành',
                  button: true,
                  child: Checkbox(
                    value: item.isCompleted,
                    activeColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) {
                      setState(() {
                        _checklist[index] = item.copyWith(isCompleted: val ?? false);
                      });
                      _autoSave();
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: item.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: item.isCompleted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nội dung mục...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (val) {
                      _checklist[index] = item.copyWith(text: val);
                      _onTextChanged();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                  tooltip: 'Xóa mục này',
                  onPressed: () {
                    setState(() {
                      _checklist.removeAt(index);
                    });
                    _autoSave();
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addChecklistItem,
          icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
          label: const Text(
            'Thêm mục mới',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
