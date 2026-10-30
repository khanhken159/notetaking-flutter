import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';

class LabelManagementScreen extends StatelessWidget {
  final NoteController controller;

  const LabelManagementScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final labels = controller.labels;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Quản lý nhãn',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Create Label Card
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: () => _showAddLabelDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: AppColors.primary, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Tạo nhãn mới',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Labels List Header
              Row(
                children: [
                  const Text(
                    'DANH SÁCH NHÃN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${labels.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (labels.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Chưa có nhãn nào. Nhấn "+ Tạo nhãn mới" để bắt đầu.',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                )
              else
                ...labels.map((lbl) => _buildLabelItem(context, lbl)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabelItem(BuildContext context, Label label) {
    final noteCount = controller.getNoteCountForLabel(label.id);
    final color = getLabelColor(label.colorId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.primary,
            shape: BoxShape.circle,
            border: Border.all(color: color.border, width: 2),
          ),
        ),
        title: Text(
          label.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$noteCount ghi chú',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
              tooltip: 'Đổi tên hoặc màu nhãn',
              onPressed: () => _showEditLabelDialog(context, label),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              tooltip: 'Xóa nhãn',
              onPressed: () => _confirmDeleteLabel(context, label, noteCount),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLabelDialog(BuildContext context) {
    String name = '';
    String selectedColorId = 'indigo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tạo nhãn mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhãn',
                      hintText: 'Nhập tên nhãn...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chọn màu:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: prototypeColors.map((pc) {
                      final isSelected = pc.id == selectedColorId;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorId = pc.id;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: pc.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 20, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.trim().isNotEmpty) {
                    controller.createLabel(name.trim(), selectedColorId);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Tạo'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLabelDialog(BuildContext context, Label label) {
    String name = label.name;
    String selectedColorId = label.colorId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sửa nhãn'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Tên nhãn',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chọn màu:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: prototypeColors.map((pc) {
                      final isSelected = pc.id == selectedColorId;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorId = pc.id;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: pc.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 20, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (name.trim().isNotEmpty) {
                    controller.updateLabel(label.id, name.trim(), selectedColorId);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteLabel(BuildContext context, Label label, int noteCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa nhãn "${label.name}"?'),
        content: Text(
          noteCount > 0
              ? 'Nhãn này đang được gắn vào $noteCount ghi chú. Khi xóa, các ghi chú này sẽ không còn nhãn này nữa (nhưng nội dung ghi chú vẫn được giữ nguyên).'
              : 'Bạn có chắc chắn muốn xóa nhãn này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteLabel(label.id);
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
}
