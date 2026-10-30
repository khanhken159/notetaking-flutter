import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';
import '../widgets/note_card.dart';
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

  void _navigateToEditNote(BuildContext context, Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(controller: controller, note: note),
      ),
    );
  }
}
