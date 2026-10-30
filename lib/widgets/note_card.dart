import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final List<Label> allLabels;
  final VoidCallback onTap;
  final VoidCallback onPinToggle;

  const NoteCard({
    super.key,
    required this.note,
    required this.allLabels,
    required this.onTap,
    required this.onPinToggle,
  });

  @override
  Widget build(BuildContext context) {
    final noteLabels = allLabels.where((l) => note.labelIds.contains(l.id)).toList();
    final timeStr = formatVietnameseTime(note.updatedAt);
    final pinSemanticLabel = note.isPinned ? 'Bỏ ghim ghi chú' : 'Ghim ghi chú';

    return Semantics(
      label: 'Ghi chú ${note.title.isNotEmpty ? note.title : "không có tiêu đề"}, '
          '${note.isPinned ? "đã ghim" : "chưa ghim"}, cập nhật $timeStr',
      button: true,
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Pin Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isNotEmpty ? note.title : 'Chưa có tiêu đề',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: note.title.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      label: pinSemanticLabel,
                      button: true,
                      child: InkWell(
                        onTap: onPinToggle,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 20,
                            color: note.isPinned
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Content or Checklist
                if (note.checklist.isNotEmpty)
                  _buildChecklistPreview()
                else if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Labels
                if (noteLabels.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: noteLabels.map((lbl) {
                      final c = getLabelColor(lbl.colorId);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.border, width: 0.5),
                        ),
                        child: Text(
                          lbl.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: c.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistPreview() {
    final displayItems = note.checklist.take(3).toList();
    final remaining = note.checklist.length - displayItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 15,
                  color: item.isCompleted ? AppColors.success : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.isCompleted
                          ? AppColors.textTertiary
                          : AppColors.textSecondary,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+ $remaining mục khác...',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}
