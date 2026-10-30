import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final ActiveTab currentTab;
  final ValueChanged<ActiveTab> onTabSelected;
  final int trashCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.trashCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: ActiveTab.notes,
                icon: Icons.note_alt_outlined,
                activeIcon: Icons.note_alt,
                label: 'Ghi chú',
              ),
              _buildNavItem(
                tab: ActiveTab.search,
                icon: Icons.search,
                activeIcon: Icons.search,
                label: 'Tìm kiếm',
              ),
              _buildNavItem(
                tab: ActiveTab.labels,
                icon: Icons.label_outline,
                activeIcon: Icons.label,
                label: 'Nhãn',
              ),
              _buildNavItem(
                tab: ActiveTab.trash,
                icon: Icons.delete_outline,
                activeIcon: Icons.delete,
                label: 'Thùng rác',
                badgeCount: trashCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required ActiveTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = currentTab == tab;
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: Semantics(
        label: '$label${badgeCount > 0 ? ", $badgeCount mục" : ""}',
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () => onTabSelected(tab),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      size: 24,
                      color: color,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
