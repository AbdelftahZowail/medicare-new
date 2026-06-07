import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/doctor_card.dart';
import '../data/doctor_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _doctorService = DoctorService();
  final _patientService = PatientService();
  final _searchController = TextEditingController();

  final Set<int> _favoritedDoctorIds = <int>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBrowseDoctors({String? query}) {
    final q = query?.trim();
    final uri = Uri(
      path: AppRoutes.patientBrowseDoctors,
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                onNotificationsTap: () => context.push(AppRoutes.patientNotifications),
              ),
              const SizedBox(height: 12),
              _SearchBar(
                controller: _searchController,
                onSubmitted: (v) => _openBrowseDoctors(query: v),
              ),
              const SizedBox(height: 18),
              Text('Services', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 4),
              Text(
                'How can we help you today',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              _ServiceCard(
                title: 'Clinic Booking',
                onTap: () => context.push(AppRoutes.patientSpecializations),
              ),
              const SizedBox(height: 18),
              Text('Popular Doctors', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _doctorService.getPopularDoctors(),
                builder: (context, snapshot) {
                  final doctors = snapshot.data ?? const [];
                  if (snapshot.connectionState == ConnectionState.waiting && doctors.isEmpty) {
                    return const SizedBox(
                      height: 190,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final d = doctors[index];
                        final isFav = _favoritedDoctorIds.contains(d.id) || d.isFavorited;
                        final doctorAssets = [
                          AssetPaths.doctorPhoto1,
                          AssetPaths.doctorPhoto2,
                          AssetPaths.doctorPhoto3,
                        ];
                        return DoctorCard(
                          imageAsset: doctorAssets[index % doctorAssets.length],
                          name: d.fullName,
                          specialization: d.specialization,
                          rating: d.averageRating,
                          reviewsCount: d.totalReviews,
                          fee: d.consultationFee,
                          location: d.clinicArea,
                          isFavorite: isFav,
                          onFavoriteToggle: () async {
                            await _patientService.favoriteToggle(d.id);
                            if (!mounted) return;
                            setState(() {
                              if (isFav) {
                                _favoritedDoctorIds.remove(d.id);
                              } else {
                                _favoritedDoctorIds.add(d.id);
                              }
                            });
                          },
                          onTap: () => context.push('${AppRoutes.patientDoctorProfile}/${d.id}'),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: doctors.length,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Community', style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 10),
              _CommunityCard(
                onJoinTap: () => context.go(AppRoutes.patientCommunity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.health_and_safety, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text('Medicare', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: AppColors.textOnPrimary, size: 22),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          // Voice search removed — no speech_to_text package available
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                AssetPaths.illustrationOnlineDoctor,
                height: 64,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({required this.onJoinTap});

  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              AssetPaths.illustrationDoctorsCuate,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onJoinTap,
            child: const Text('Join Our Community'),
          ),
        ),
      ],
    );
  }
}

