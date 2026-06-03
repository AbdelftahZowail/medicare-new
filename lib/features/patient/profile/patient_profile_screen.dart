import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_profile_service.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _service = PatientProfileService();
  bool _loading = true;
  PatientProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile = null;
        _loading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile. Please try again.')),
        );
      }
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.patientHome);
        break;
      case 1:
        context.go(AppRoutes.patientAppointments);
        break;
      case 2:
        context.go(AppRoutes.patientCommunity);
        break;
      case 3:
        context.go(AppRoutes.patientBrowseDoctors);
        break;
      case 4:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.patientNotifications),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Photo
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary100,
                            backgroundImage: AssetImage(AssetPaths.patientProfile1),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.patientEditProfile),
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: AppColors.textOnPrimary, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _profile?.fullName ?? '',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile?.email ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile?.phoneNumber ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                      // Health Info Section
                      if (_profile?.bloodType != null ||
                          _profile?.allergies != null ||
                          _profile?.chronicDiseases != null) ...[
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text('Health Information', style: AppTextStyles.heading3),
                        ),
                        const SizedBox(height: 12),
                        if (_profile?.bloodType != null)
                          _HealthCard(
                            icon: Icons.bloodtype,
                            title: 'Blood Type',
                            value: _profile!.bloodType!,
                          ),
                        if (_profile?.allergies != null && _profile!.allergies!.isNotEmpty)
                          _HealthCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Allergies',
                            value: _profile!.allergies!,
                          ),
                        if (_profile?.chronicDiseases != null && _profile!.chronicDiseases!.isNotEmpty)
                          _HealthCard(
                            icon: Icons.medical_services_outlined,
                            title: 'Chronic Diseases',
                            value: _profile!.chronicDiseases!,
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Add Family Member Button
                      AppButton(
                        text: 'Add Family Member',
                        isSmall: true,
                        icon: Icons.person_add,
                        onPressed: () => context.push(AppRoutes.patientAddFamilyMember),
                      ),
                      const SizedBox(height: 24),

                      // Menu Items
                      _MenuItem(
                        icon: Icons.medical_services_outlined,
                        title: 'Medical History',
                        onTap: () => context.push(AppRoutes.patientMedicalHistory),
                      ),
                      _MenuItem(
                        icon: Icons.favorite_outline,
                        title: 'My Favorites',
                        onTap: () => context.push(AppRoutes.patientFavorites),
                      ),
                      _MenuItem(
                        icon: Icons.people_outline,
                        title: 'Family Members',
                        onTap: () => context.push(AppRoutes.patientFamilyMembers),
                      ),
                      _MenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        onTap: () => context.push(AppRoutes.patientEditProfile),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'About Medicare',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Medicare',
                            applicationVersion: '1.0.0',
                            applicationLegalese: 'Your trusted healthcare companion.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _ProfileBottomNav(
        currentIndex: 4,
        onTap: _onNavTap,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTextStyles.labelLarge),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _HealthCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _ProfileBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
      _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today, label: 'Appointments'),
      _NavItemData(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'AI Bot'),
      _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Nearby'),
      _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                      Icon(
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
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
}
