import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final Function(int) onTap;
  final int? centerFabIndex;
  final IconData? centerFabIcon;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.centerFabIndex,
    this.centerFabIcon,
  });

  @override
  Widget build(BuildContext context) {
    final hasFab = centerFabIndex != null && centerFabIndex! >= 0 && centerFabIndex! < items.length;

    if (hasFab) {
      return _buildFabStyle(context);
    }

    return _buildStandardStyle(context);
  }

  Widget _buildStandardStyle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      item.imageAsset != null
                          ? Image.asset(
                              item.imageAsset!,
                              height: 24,
                              width: 24,
                              color: isSelected ? AppColors.primary : AppColors.textTertiary,
                              colorBlendMode: BlendMode.srcIn,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppColors.primary : AppColors.textTertiary,
                              size: 24,
                            ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFabStyle(BuildContext context) {
    const barHeight = 86.0;
    const fabSize = 62.0;
    final fabIdx = centerFabIndex!;

    final leftItems = items.sublist(0, fabIdx);
    final rightItems = items.sublist(fabIdx + 1);

    return SizedBox(
      height: barHeight + 14,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ...leftItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isSelected = idx == currentIndex;
                  return Expanded(
                    child: _NavItem(
                      label: item.label,
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      isSelected: isSelected,
                      onTap: () => onTap(idx),
                      imageAsset: item.imageAsset,
                    ),
                  );
                }),
                const SizedBox(width: fabSize),
                ...rightItems.asMap().entries.map((entry) {
                  final idx = entry.key + fabIdx + 1;
                  final item = entry.value;
                  final isSelected = idx == currentIndex;
                  return Expanded(
                    child: _NavItem(
                      label: item.label,
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      isSelected: isSelected,
                      onTap: () => onTap(idx),
                      imageAsset: item.imageAsset,
                    ),
                  );
                }),
              ],
            ),
          ),
          Positioned(
            bottom: 22,
            child: GestureDetector(
              onTap: () => onTap(fabIdx),
              child: Container(
                height: fabSize,
                width: fabSize,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: items[fabIdx].imageAsset != null
                      ? Image.asset(
                          items[fabIdx].imageAsset!,
                          height: 26,
                          width: 26,
                          colorBlendMode: BlendMode.srcIn,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          centerFabIcon ?? items[fabIdx].icon,
                          color: AppColors.textOnPrimary,
                          size: 26,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    this.imageAsset,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 38,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      height: 22,
                      width: 22,
                      color: fg,
                      colorBlendMode: BlendMode.srcIn,
                      fit: BoxFit.contain,
                    )
                  : Icon(isSelected ? selectedIcon : icon, color: fg, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: fg,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? imageAsset;

  BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.imageAsset,
  });
}

// Role-specific bottom nav configurations
class PatientNavItems {
  static List<BottomNavItem> get items => [
        BottomNavItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
        ),
        BottomNavItem(
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          label: 'Appointments',
        ),
        BottomNavItem(
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble,
          label: 'AI Bot',
          imageAsset: 'assets/images/shady_ai_icon.png',
        ),
        BottomNavItem(
          icon: Icons.location_on_outlined,
          selectedIcon: Icons.location_on,
          label: 'Nearby',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
        ),
      ];
}

class DoctorNavItems {
  static List<BottomNavItem> get items => [
        BottomNavItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        BottomNavItem(
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          label: 'Schedule',
        ),
        BottomNavItem(
          icon: Icons.chat_bubble_outline,
          selectedIcon: Icons.chat_bubble,
          label: 'Community',
          imageAsset: 'assets/images/shady_ai_icon.png',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
        ),
      ];
}

class ClinicNavItems {
  static List<BottomNavItem> get items => [
        BottomNavItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        BottomNavItem(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Doctors',
        ),
        BottomNavItem(
          icon: Icons.payments_outlined,
          selectedIcon: Icons.payments,
          label: 'Payments',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profile',
        ),
      ];
}
