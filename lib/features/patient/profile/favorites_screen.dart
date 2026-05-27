import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/services/patient_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = PatientService();
  bool _loading = true;
  List<DoctorListItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final favorites = await _service.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load favorites: ${e.toString()}')),
      );
      setState(() {
        _favorites = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadFavorites,
                child: _favorites.isEmpty
                    ? _EmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final doctor = _favorites[index];
                        final doctorAssets = [
                          AssetPaths.doctorPhoto1,
                          AssetPaths.doctorPhoto2,
                          AssetPaths.doctorPhoto3,
                          AssetPaths.doctorPhoto4,
                        ];
                        return DoctorCard(
                          imageAsset: doctorAssets[index % doctorAssets.length],
                          name: doctor.fullName,
                          specialization: doctor.specialization,
                          rating: doctor.averageRating,
                          reviewsCount: doctor.totalReviews,
                          fee: doctor.consultationFee,
                          location: doctor.clinicArea,
                          isFavorite: true,
                          onFavoriteToggle: () {
                            setState(() {
                              _favorites.removeAt(index);
                            });
                          },
                          onTap: () => context.push('${AppRoutes.patientDoctorProfile}/${doctor.id}'),
                        );
                        },
                      ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No favorites yet',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favorite doctors here for quick access.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
