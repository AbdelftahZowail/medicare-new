import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
  final _searchController = TextEditingController();

  int _navIndex = 0;
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

  void _onNavTap(int index) {
    setState(() => _navIndex = index);

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
        context.go(AppRoutes.patientNearby);
        break;
      case 4:
        context.go(AppRoutes.patientProfile);
        break;
    }
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
                          onFavoriteToggle: () {
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
      bottomNavigationBar: _PatientBottomNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
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

class _PatientBottomNavBar extends StatelessWidget {
  const _PatientBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const barHeight = 86.0;
    const fabSize = 62.0;

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
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  label: 'Appointments',
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: fabSize),
                _NavItem(
                  label: 'Nearby',
                  icon: Icons.location_on_outlined,
                  selectedIcon: Icons.location_on,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  label: 'Profile',
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 22,
            child: GestureDetector(
              onTap: () => onTap(2),
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
                  child: const Icon(Icons.smart_toy_outlined, color: AppColors.textOnPrimary, size: 26),
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
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
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
              child: Icon(isSelected ? selectedIcon : icon, color: fg, size: 22),
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
      ),
    );
  }
}
