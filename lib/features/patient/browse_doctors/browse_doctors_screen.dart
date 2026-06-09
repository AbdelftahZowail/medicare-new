import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/services/patient_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/doctor_card.dart';
import '../data/doctor_service.dart';

class BrowseDoctorsScreen extends StatefulWidget {
  const BrowseDoctorsScreen({super.key});

  @override
  State<BrowseDoctorsScreen> createState() => _BrowseDoctorsScreenState();
}

class _BrowseDoctorsScreenState extends State<BrowseDoctorsScreen> {
  final DoctorService _service = DoctorService();
  final PatientService _patientService = PatientService();
  final TextEditingController _controller = TextEditingController();

  bool _loading = true;
  List<DoctorListItem> _items = const [];
  String? _specialization;

  bool _initialLoadDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    final extra = state.extra;
    if (extra is Map<String, dynamic>) {
      _specialization = extra['specialization'] as String?;
    }
    final query = state.uri.queryParameters['q'];
    if (query != null && query.isNotEmpty && _controller.text.isEmpty) {
      _controller.text = query;
    }
    if (!_initialLoadDone) {
      _initialLoadDone = true;
      _load();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _service.browseDoctors(
      query: _controller.text,
      specialization: _specialization,
    );
    if (!mounted) return;
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Doctors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.patientHome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _load(),
                decoration: InputDecoration(
                  hintText: _specialization == null
                      ? 'Search doctors'
                      : 'Search $_specialization doctors',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No doctors found',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final d = _items[i];
                    final doctorAssets = [
                      AssetPaths.doctorPhoto1,
                      AssetPaths.doctorPhoto2,
                      AssetPaths.doctorPhoto3,
                      AssetPaths.doctorPhoto4,
                    ];
                    return DoctorCard(
                      imageAsset: doctorAssets[i % doctorAssets.length],
                      name: d.fullName,
                      specialization: d.specialization,
                      rating: d.averageRating,
                      reviewsCount: d.totalReviews,
                      fee: d.consultationFee,
                      location: '${d.clinicArea ?? ''}${(d.clinicArea != null && d.clinicName != null) ? ', ' : ''}${d.clinicName ?? ''}',
                      isFavorite: d.isFavorited,
                      onTap: () => context.push('${AppRoutes.patientDoctorProfile}/${d.id}'),
                      onFavoriteToggle: () async {
                        await _patientService.favoriteToggle(d.id);
                        setState(() => _items[i] = DoctorListItem(
                          id: d.id,
                          fullName: d.fullName,
                          specialization: d.specialization,
                          profileImageUrl: d.profileImageUrl,
                          consultationFee: d.consultationFee,
                          averageRating: d.averageRating,
                          totalReviews: d.totalReviews,
                          isAvailable: d.isAvailable,
                          clinicName: d.clinicName,
                          clinicArea: d.clinicArea,
                          isFavorited: !d.isFavorited,
                        ));
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
