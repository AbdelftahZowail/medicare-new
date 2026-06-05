import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bloc/auth_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/debug_account_switcher.dart';
import '../../doctor/services/doctor_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _service = DoctorService();
  int _navIndex = 3;

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.doctorDashboard);
        break;
      case 1:
        context.go(AppRoutes.doctorAppointments);
        break;
      case 2:
        context.go(AppRoutes.doctorCommunity);
        break;
      case 3:
        context.go(AppRoutes.doctorProfile);
        break;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
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
      body: SafeArea(
        child: FutureBuilder(
          future: _service.getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error?.toString() ?? 'Failed to load profile',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final profile = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(
                    name: profile?.fullName ?? '',
                    specialization: profile?.specialization ?? '',
                    imageUrl: profile?.profileImageUrl,
                    rating: profile?.averageRating ?? 0,
                    reviewsCount: profile?.totalReviews ?? 0,
                  ),
                  const SizedBox(height: 16),
                  _StatsRow(
                    experience: profile?.yearsOfExperience ?? 0,
                    patients: 0,
                    rating: profile?.averageRating ?? 0,
                  ),
                  const SizedBox(height: 20),
                  _ProfessionalDetailsCard(profile: profile),
                  const SizedBox(height: 16),
                  _EducationCard(profile: profile),
                  const SizedBox(height: 16),
                  if (profile?.associatedClinics.isNotEmpty == true) ...[
                    Text(
                      'Associated Clinics',
                      style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    ...profile!.associatedClinics.map((clinic) => _ClinicCard(name: clinic)),
                    const SizedBox(height: 16),
                  ],
                  if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                    Text(
                      'Professional Bio',
                      style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(
                        profile.bio!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.doctorEditProfile),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final prof = await _service.getProfile();
                          if (mounted) {
                            context.push(
                              AppRoutes.doctorSchedule,
                              extra: {'doctorId': prof.id},
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: const Text('Manage My Schedule'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.doctorQrCode),
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text('View QR Code'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
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
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        items: DoctorNavItems.items,
        onTap: _onNavTap,
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String specialization;
  final String? imageUrl;
  final double rating;
  final int reviewsCount;

  const _ProfileHeader({
    required this.name,
    required this.specialization,
    this.imageUrl,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary200, width: 2),
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(AssetPaths.doctorJulian),
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(AssetPaths.doctorJulian),
                  ),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(specialization, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Text(
                '($reviewsCount reviews)',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int experience;
  final int patients;
  final double rating;

  const _StatsRow({
    required this.experience,
    required this.patients,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '$experience+',
            label: 'Years Exp.',
            icon: Icons.work_outline,
          ),
          const VerticalDivider(width: 24),
          _StatItem(
            value: patients.toString(),
            label: 'Patients',
            icon: Icons.people_outline,
          ),
          const VerticalDivider(width: 24),
          _StatItem(
            value: rating.toStringAsFixed(1),
            label: 'Rating',
            icon: Icons.star_outline,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _ProfessionalDetailsCard extends StatelessWidget {
  final DoctorProfile? profile;

  const _ProfessionalDetailsCard({this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Details',
            style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Specialty', value: profile?.specialization ?? ''),
          _DetailRow(label: 'Sub-Specialty', value: profile?.subSpecialty ?? ''),
          _DetailRow(label: 'Experience', value: '${profile?.yearsOfExperience ?? 0} Years'),
          _DetailRow(
            label: 'Languages',
            value: profile?.languages != null ? profile!.languages.join(', ') : '',
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final DoctorProfile? profile;

  const _EducationCard({this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education & Certifications',
            style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'University', value: profile?.university ?? ''),
          _DetailRow(label: 'Degree', value: profile?.degree ?? ''),
          _DetailRow(label: 'Graduation Year', value: '${profile?.graduationYear ?? 0}'),
          _DetailRow(label: 'Board Certification', value: profile?.boardCertification ?? ''),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final String name;

  const _ClinicCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_hospital, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }
}
