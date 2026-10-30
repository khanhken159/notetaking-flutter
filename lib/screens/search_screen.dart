import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';
import '../models/note.dart';
import '../models/initial_data.dart';
import '../theme/app_colors.dart';
import '../widgets/note_card.dart';
import '../widgets/pin_dialog.dart';
import 'note_editor_screen.dart';

class SearchScreen extends StatefulWidget {
  final NoteController controller;

  const SearchScreen({super.key, required this.controller});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLabelId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final query = _searchController.text.trim();
        final results = widget.controller.storage.searchAndFilter(
          query: query,
          labelId: _selectedLabelId,
          sortOption: SortOption.updatedDesc,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề, nội dung...',
                hintStyle: const TextStyle(fontSize: 15, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: _buildLabelFilterChips(),
            ),
          ),
          body: _buildBody(query, results),
        );
      },
    );
  }

  Widget _buildLabelFilterChips() {
    final allLabels = widget.controller.labels;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allLabels.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedLabelId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Tất cả nhãn'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedLabelId = null;
                  });
                },
                selectedColor: AppColors.primaryLight,
                labelStyle: TextStyle(
                  fontSize: 12,
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
          final isSelected = _selectedLabelId == label.id;
          final color = getLabelColor(label.colorId);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.primary,
                  shape: BoxShape.circle,
                ),
              ),
              label: Text(label.name),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedLabelId = isSelected ? null : label.id;
                });
              },
              selectedColor: color.background,
              labelStyle: TextStyle(
                fontSize: 12,
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

  Widget _buildBody(String query, List<Note> results) {
    if (query.isEmpty && _selectedLabelId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Icon(Icons.search, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tìm kiếm ghi chú',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập từ khóa hoặc chọn nhãn bên trên để tìm nhanh ghi chú mong muốn.',
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

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Không có ghi chú nào phù hợp với "$query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Tìm thấy ${results.length} ghi chú',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        ...results.map((note) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NoteCard(
            note: note,
            allLabels: widget.controller.labels,
            onTap: () async {
              if (note.isLocked) {
                final isVerified = await PinDialog.showVerify(
                  context: context,
                  title: 'Mở khóa ghi chú',
                  subtitle: 'Ghi chú này đã được bảo vệ bằng mã PIN',
                  onVerify: (pin) async => widget.controller.verifyPin(pin),
                );
                if (isVerified != true) return;
              }

              if (!mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(
                    controller: widget.controller,
                    note: note,
                  ),
                ),
              );
            },
            onPinToggle: () => widget.controller.togglePin(note.id),
          ),
        )),
      ],
    );
  }
}
