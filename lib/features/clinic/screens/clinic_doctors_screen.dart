import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../clinic/clinic_service.dart';

class ClinicDoctorsScreen extends StatefulWidget {
  const ClinicDoctorsScreen({super.key});

  @override
  State<ClinicDoctorsScreen> createState() => _ClinicDoctorsScreenState();
}

class _ClinicDoctorsScreenState extends State<ClinicDoctorsScreen> {
  final _service = ClinicService();
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final doctors = await _service.getClinicDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadDoctors,
                    child: _doctors.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _doctors[index];
                              return _DoctorCard(
                                doctor: doctor,
                                index: index,
                                onTap: () => context.push('${AppRoutes.clinicDoctorDetail}/${doctor.id}'),
                              );
                            },
                          ),
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.clinicScanQr),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Add Doctor'),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Failed to load doctors',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'No doctors yet',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan a doctor\'s QR code to add them',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.clinicScanQr),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final dynamic doctor;
  final int index;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.index,
    required this.onTap,
  });

  String _doctorAsset(int idx) {
    const assets = [
      AssetPaths.drJamesWilson,
      AssetPaths.drSarahChen,
      AssetPaths.doctorJulian,
      AssetPaths.doctorJulian2,
      AssetPaths.drSarahChen2,
      AssetPaths.sarahJohnson,
      AssetPaths.emilyDavis,
      AssetPaths.doctorPhoto1,
      AssetPaths.doctorPhoto2,
      AssetPaths.doctorPhoto3,
      AssetPaths.doctorPhoto4,
    ];
    return assets[idx % assets.length];
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = doctor.isAvailable ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: doctor.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          doctor.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            _doctorAsset(index),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Image.asset(
                        _doctorAsset(index),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName ?? '',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization ?? '',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: isAvailable ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isAvailable ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${doctor.consultationFee?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
