import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';
import '../widgets/note_card.dart';
import '../widgets/pin_dialog.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  final NoteController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pinnedNotes = controller.pinnedNotes;
        final otherNotes = controller.otherNotes;
        final totalCount = controller.activeNotes.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ghi chú',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$totalCount ghi chú',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              // Security PIN settings
              Semantics(
                label: 'Cài đặt mã PIN bảo vệ ghi chú',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  tooltip: 'Mã PIN bảo mật (1234)',
                  onPressed: () => _managePin(context),
                ),
              ),

              // Grid / List toggle
              Semantics(
                label: controller.viewMode == ViewMode.grid
                    ? 'Chuyển sang chế độ danh sách'
                    : 'Chuyển sang chế độ lưới',
                button: true,
                child: IconButton(
                  icon: Icon(
                    controller.viewMode == ViewMode.grid
                        ? Icons.view_agenda_outlined
                        : Icons.grid_view_outlined,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: controller.viewMode == ViewMode.grid
                      ? 'Xem danh sách'
                      : 'Xem lưới',
                  onPressed: () => controller.toggleViewMode(),
                ),
              ),

              // Sort menu
              Semantics(
                label: 'Sắp xếp ghi chú',
                button: true,
                child: PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort, color: AppColors.textSecondary),
                  tooltip: 'Sắp xếp',
                  onSelected: (option) => controller.setSortOption(option),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SortOption.updatedDesc,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: controller.sortOption == SortOption.updatedDesc
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 8),
                          const Text('Mới cập nhật'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: SortOption.updatedAsc,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: controller.sortOption == SortOption.updatedAsc
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 8),
                          const Text('Cũ nhất'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: SortOption.titleAsc,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: controller.sortOption == SortOption.titleAsc
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 8),
                          const Text('Theo tên (A-Z)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: _buildLabelFilterBar(context),
            ),
          ),
          body: totalCount == 0
              ? _buildEmptyState(context)
              : _buildNotesList(context, pinnedNotes, otherNotes),
          floatingActionButton: Semantics(
            label: 'Tạo ghi chú mới',
            button: true,
            child: FloatingActionButton(
              onPressed: () => _navigateToCreateNote(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabelFilterBar(BuildContext context) {
    final allLabels = controller.labels;
    final selectedId = controller.selectedLabelId;
    final totalActive = controller.storage.getActiveNotes().length;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allLabels.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('Tất cả ($totalActive)'),
                selected: isSelected,
                onSelected: (_) => controller.setSelectedLabel(null),
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                ),
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              ),
            );
          }

          final label = allLabels[index - 1];
          final isSelected = selectedId == label.id;
          final count = controller.getNoteCountForLabel(label.id);
          final color = getLabelColor(label.colorId);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color.primary,
                  shape: BoxShape.circle,
                ),
              ),
              label: Text('${label.name} ($count)'),
              selected: isSelected,
              onSelected: (_) => controller.setSelectedLabel(label.id),
              selectedColor: color.background,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color.primary : AppColors.textSecondary,
              ),
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? color.primary : AppColors.border,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.note_alt_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có ghi chú nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút "+" bên dưới để tạo ghi chú đầu tiên của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateNote(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo ghi chú mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(
    BuildContext context,
    List<Note> pinnedNotes,
    List<Note> otherNotes,
  ) {
    final isGrid = controller.viewMode == ViewMode.grid;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _buildFeatureBanner(context),
        const SizedBox(height: 14),
        if (pinnedNotes.isNotEmpty) ...[
          _buildSectionHeader('ĐÃ GHIM', pinnedNotes.length),
          const SizedBox(height: 8),
          if (isGrid)
            _buildGridSection(context, pinnedNotes)
          else
            _buildListSection(context, pinnedNotes),
          const SizedBox(height: 20),
        ],
        if (otherNotes.isNotEmpty) ...[
          if (pinnedNotes.isNotEmpty) _buildSectionHeader('KHÁC', otherNotes.length),
          if (pinnedNotes.isNotEmpty) const SizedBox(height: 8),
          if (isGrid)
            _buildGridSection(context, otherNotes)
          else
            _buildListSection(context, otherNotes),
        ],
      ],
    );
  }

  Widget _buildFeatureBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.tips_and_updates, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ Đã cập nhật tính năng mới:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.3),
                    children: [
                      const TextSpan(text: '• Khóa ghi chú: Chạm ghi chú '),
                      const TextSpan(
                        text: '🔒 Kế hoạch tài chính',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' bên dưới, nhập PIN '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                          ),
                          child: const Text(
                            '1234',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFB45309)),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' để mở!\n'),
                      const TextSpan(text: '• Ghi âm: Mở bất kỳ ghi chú nào và chạm icon 🎙️ ở thanh trên để thu âm giọng nói.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridSection(BuildContext context, List<Note> notes) {
    // 2 columns
    final leftNotes = <Note>[];
    final rightNotes = <Note>[];
    for (int i = 0; i < notes.length; i++) {
      if (i % 2 == 0) {
        leftNotes.add(notes[i]);
      } else {
        rightNotes.add(notes[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftNotes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NoteCard(
                key: ValueKey(note.id),
                note: note,
                allLabels: controller.labels,
                onTap: () => _navigateToEditNote(context, note),
                onPinToggle: () => controller.togglePin(note.id),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: rightNotes.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NoteCard(
                key: ValueKey(note.id),
                note: note,
                allLabels: controller.labels,
                onTap: () => _navigateToEditNote(context, note),
                onPinToggle: () => controller.togglePin(note.id),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(BuildContext context, List<Note> notes) {
    return Column(
      children: notes.map((note) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NoteCard(
          key: ValueKey(note.id),
          note: note,
          allLabels: controller.labels,
          onTap: () => _navigateToEditNote(context, note),
          onPinToggle: () => controller.togglePin(note.id),
        ),
      )).toList(),
    );
  }

  void _navigateToCreateNote(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(controller: controller),
      ),
    );
  }

  void _navigateToEditNote(BuildContext context, Note note) async {
    if (note.isLocked) {
      final isVerified = await PinDialog.showVerify(
        context: context,
        title: 'Mở khóa ghi chú',
        subtitle: 'Nhập mã PIN gồm 4 số để mở (Mặc định: 1234)',
        onVerify: (pin) async => controller.verifyPin(pin),
      );
      if (isVerified != true) return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(controller: controller, note: note),
      ),
    );
  }

  void _managePin(BuildContext context) async {
    final currentPin = controller.storage.getLockPin() ?? '1234';
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Bảo mật & Mã PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tính năng khóa ghi chú bảo vệ những ghi chú riêng tư do bạn chọn.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Mã PIN hiện tại: $currentPin',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('change'),
            child: const Text('Đổi mã PIN mới'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );

    if (action == 'change' && context.mounted) {
      final newPin = await PinDialog.showSetup(
        context: context,
        title: 'Đổi mã PIN mới',
        subtitle: 'Nhập 4 số PIN mới để bảo vệ ghi chú',
      );
      if (newPin != null) {
        await controller.setLockPin(newPin);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật mã PIN thành công!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    }
  }
}
