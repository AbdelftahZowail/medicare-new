import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/debug_account_switcher.dart';
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

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
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
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary100,
                            backgroundImage: _profile?.profileImageUrl != null && _profile!.profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profile!.profileImageUrl!)
                                : null,
                            child: (_profile?.profileImageUrl == null || _profile!.profileImageUrl!.isEmpty)
                                ? const Icon(Icons.person, color: AppColors.primary, size: 50)
                                : null,
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
                      const SizedBox(height: 20),
                      // Personal Details Section
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text('Personal Details', style: AppTextStyles.heading3),
                      ),
                      const SizedBox(height: 12),
                      if (_profile?.dateOfBirth != null)
                        _HealthCard(
                          icon: Icons.calendar_today,
                          title: 'Date of Birth',
                          value: '${_profile!.dateOfBirth!.day}/${_profile!.dateOfBirth!.month}/${_profile!.dateOfBirth!.year}',
                        ),
                      if (_profile?.age != null)
                        _HealthCard(
                          icon: Icons.cake,
                          title: 'Age',
                          value: '${_profile!.age} years',
                        ),
                      if (_profile?.gender != null)
                        _HealthCard(
                          icon: Icons.person,
                          title: 'Gender',
                          value: _profile!.gender == 0 ? 'Male' : 'Female',
                        ),
                      if (_profile?.address != null)
                        _HealthCard(
                          icon: Icons.location_on,
                          title: 'Address',
                          value: _profile!.address!,
                        ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      if (kEnableDebugTools) ...[
                        const DebugAccountSwitcher(),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
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

