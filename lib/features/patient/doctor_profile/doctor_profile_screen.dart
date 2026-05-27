import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../data/doctor_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  final int doctorId;
  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _service = DoctorService();

  bool _loading = true;
  DoctorProfile? _doctor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _service.getDoctorProfile(widget.doctorId);
    if (!mounted) return;
    setState(() {
      _doctor = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary100,
                          backgroundImage: AssetImage(AssetPaths.doctorPhoto1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_doctor?.fullName ?? '', style: AppTextStyles.heading3),
                              const SizedBox(height: 4),
                              Text(
                                _doctor?.specialization ?? '',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Text('Fee', style: AppTextStyles.bodyMedium),
                          const Spacer(),
                          Text(
                            '${(_doctor?.consultationFee ?? 0).toStringAsFixed(0)} EGP',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    AppButton(
                      text: 'Book Appointment',
                      onPressed: () {
                        context.go(
                          AppRoutes.patientBookAppointment,
                          extra: {'doctorId': widget.doctorId},
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'My Appointments',
                      isOutlined: true,
                      onPressed: () => context.go(AppRoutes.patientAppointments),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
