import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_appointments_service.dart';

class QueueTrackerScreen extends StatefulWidget {
  final int appointmentId;
  const QueueTrackerScreen({super.key, required this.appointmentId});

  @override
  State<QueueTrackerScreen> createState() => _QueueTrackerScreenState();
}

class _QueueTrackerScreenState extends State<QueueTrackerScreen> {
  final _service = PatientAppointmentsService();
  bool _loading = true;
  LiveQueueTracker? _tracker;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadTracker();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadTracker();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTracker() async {
    try {
      final tracker = await _service.getQueueTracker(widget.appointmentId);
      if (!mounted) return;
      setState(() {
        _tracker = tracker;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tracker = null;
        _loading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load queue tracker. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Queue Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadTracker,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Doctor Name
                      Text(
                        _tracker?.doctorName ?? '',
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live Queue Updates',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),

                      // Large Queue Number
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Queue Number',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '#${_tracker?.myQueueNumber ?? 0}',
                              style: AppTextStyles.displayLarge.copyWith(
                                color: AppColors.primary,
                                fontSize: 64,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                              decoration: BoxDecoration(
                                color: _statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusText,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: _statusFgColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_outline,
                              label: 'Patients Ahead',
                              value: '${_tracker?.patientsAheadOfMe ?? 0}',
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer_outlined,
                              label: 'Est. Wait Time',
                              value: '${_tracker?.estimatedWaitTimeMinutes ?? 0} min',
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        icon: Icons.play_circle_outline,
                        label: 'Currently Serving',
                        value: '#${_tracker?.currentServingNumber ?? 0}',
                        color: AppColors.success,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 28),

                      // Progress Indicator
                      Container(
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
                            Text('Queue Progress', style: AppTextStyles.heading4),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progressValue,
                                minHeight: 10,
                                backgroundColor: AppColors.primary100,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${(_progressValue * 100).toStringAsFixed(0)}% complete',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        text: 'Refresh',
                        isOutlined: true,
                        onPressed: _loadTracker,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  double get _progressValue {
    if (_tracker == null) return 0;
    final total = _tracker!.myQueueNumber;
    final current = _tracker!.currentServingNumber;
    if (total <= 0) return 0;
    final progress = current / total;
    return progress.clamp(0.0, 1.0);
  }

  String get _statusText {
    final status = _tracker?.myQueueStatus;
    if (status == AppEnums.inConsultation) return 'In Consultation';
    if (status == 2) return 'Completed'; // QueueStatus.completed = 2
    if (status == AppEnums.refunded) return 'Refunded';
    return 'Waiting';
  }

  Color get _statusBgColor {
    final status = _tracker?.myQueueStatus;
    if (status == AppEnums.inConsultation) return AppColors.primary100;
    if (status == 2) return AppColors.successBg; // QueueStatus.completed = 2
    if (status == AppEnums.refunded) return AppColors.errorBg;
    return AppColors.warningBg;
  }

  Color get _statusFgColor {
    final status = _tracker?.myQueueStatus;
    if (status == AppEnums.inConsultation) return AppColors.primary;
    if (status == 2) return AppColors.success; // QueueStatus.completed = 2
    if (status == AppEnums.refunded) return AppColors.error;
    return AppColors.warning;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
