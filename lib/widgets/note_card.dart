import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';

class NoteCard extends StatefulWidget {
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
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final noteLabels = widget.allLabels.where((l) => note.labelIds.contains(l.id)).toList();
    final timeStr = formatVietnameseTime(note.updatedAt);
    final pinSemanticLabel = note.isPinned ? 'Bỏ ghim ghi chú' : 'Ghim ghi chú';

    return Semantics(
      label: 'Ghi chú ${note.title.isNotEmpty ? note.title : "không có tiêu đề"}, '
          '${note.isPinned ? "đã ghim" : "chưa ghim"}, '
          '${note.isLocked ? "đã khóa bằng mật khẩu, " : ""}'
          'cập nhật $timeStr',
      button: true,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: note.isLocked
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.border,
              width: note.isLocked ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Pin / Lock Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.isLocked) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 6, top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty
                              ? note.title
                              : (note.isLocked ? 'Ghi chú bảo mật' : 'Chưa có tiêu đề'),
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
                          onTap: widget.onPinToggle,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
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

                  // Content: if Locked, mask it
                  if (note.isLocked)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: AppColors.textTertiary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã khóa bằng mã PIN • Chạm để mở',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (note.checklist.isNotEmpty)
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

                  // Audio Attachment Badge if present
                  if (note.hasAudio) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Ghi âm ${note.audioDurationFormatted}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

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
      ),
    );
  }

  Widget _buildChecklistPreview() {
    final displayItems = widget.note.checklist.take(3).toList();
    final remaining = widget.note.checklist.length - displayItems.length;

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
