import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';

class TrashScreen extends StatelessWidget {
  final NoteController controller;

  const TrashScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final trashNotes = controller.trashNotes;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thùng rác',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${trashNotes.length} ghi chú đã xóa',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              if (trashNotes.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _confirmEmptyTrash(context),
                  icon: const Icon(Icons.delete_sweep, size: 20, color: AppColors.error),
                  label: const Text(
                    'Dọn sạch',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          body: trashNotes.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: trashNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = trashNotes[index];
                    return _buildTrashItem(context, note);
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thùng rác trống',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các ghi chú đã xóa sẽ xuất hiện tại đây.\nBạn có thể khôi phục lại hoặc xóa vĩnh viễn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashItem(BuildContext context, Note note) {
    final timeStr = formatVietnameseTime(note.deletedAt ?? note.updatedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            note.title.isNotEmpty ? note.title : 'Chưa có tiêu đề',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Content preview
          if (note.content.isNotEmpty)
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else if (note.checklist.isNotEmpty)
            Text(
              'Danh sách ${note.checklist.length} mục việc cần làm',
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),

          const SizedBox(height: 10),

          // Deleted time
          Text(
            'Đã xóa: $timeStr',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Restore button
              OutlinedButton.icon(
                onPressed: () {
                  controller.restoreNote(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã khôi phục "${note.title.isNotEmpty ? note.title : "Ghi chú"}"'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.restore, size: 18),
                label: const Text('Khôi phục'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Permanently delete button
              TextButton.icon(
                onPressed: () => _confirmDeletePermanently(context, note),
                icon: const Icon(Icons.delete_forever, size: 18, color: AppColors.error),
                label: const Text(
                  'Xóa vĩnh viễn',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeletePermanently(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa vĩnh viễn?'),
        content: Text(
          'Ghi chú "${note.title.isNotEmpty ? note.title : "Chưa có tiêu đề"}" sẽ bị xóa hoàn toàn khỏi thiết bị và không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deletePermanently(note.id);
            },
            child: const Text(
              'Xóa vĩnh viễn',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dọn sạch thùng rác?'),
        content: const Text(
          'Tất cả ghi chú trong thùng rác sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.emptyTrash();
            },
            child: const Text(
              'Dọn sạch tất cả',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
