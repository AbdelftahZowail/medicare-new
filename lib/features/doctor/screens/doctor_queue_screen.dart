import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../doctor/services/doctor_service.dart';

class DoctorQueueScreen extends StatefulWidget {
  const DoctorQueueScreen({super.key});

  @override
  State<DoctorQueueScreen> createState() => _DoctorQueueScreenState();
}

class _DoctorQueueScreenState extends State<DoctorQueueScreen> {
  final _service = DoctorService();
  List<Appointment> _queue = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadQueue();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadQueue();
    });
  }

  void _loadQueue() {
    _service.getLiveQueue().then((data) {
      if (mounted) setState(() => _queue = data);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Color _queueStatusColor(int? status) {
    switch (status) {
      case 0:
        return AppColors.warning;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.success;
      default:
        return AppColors.textTertiary;
    }
  }

  Color _queueStatusBgColor(int? status) {
    switch (status) {
      case 0:
        return AppColors.warningBg;
      case 1:
        return AppColors.primary50;
      case 2:
        return AppColors.successBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  String _queueStatusText(int? status) {
    switch (status) {
      case 0:
        return 'Waiting';
      case 1:
        return 'With Doctor';
      case 2:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Future<void> _callNext() async {
    final success = await _service.callNextPatient();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Next patient called')),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Today\'s Queue'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
            child: ElevatedButton.icon(
              onPressed: _callNext,
              icon: const Icon(Icons.call, size: 16),
              label: const Text('Call Next'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _queue.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No patients in queue today',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: _queue.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final patient = _queue[index];
                  return _QueueCard(
                    appointment: patient,
                    statusColor: _queueStatusColor(patient.queueStatus),
                    statusBgColor: _queueStatusBgColor(patient.queueStatus),
                    statusText: _queueStatusText(patient.queueStatus),
                    onStartConsultation: () {
                      context.push(
                        '${AppRoutes.doctorConsultation}/${patient.id}',
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  final Appointment appointment;
  final Color statusColor;
  final Color statusBgColor;
  final String statusText;
  final VoidCallback onStartConsultation;

  const _QueueCard({
    required this.appointment,
    required this.statusColor,
    required this.statusBgColor,
    required this.statusText,
    required this.onStartConsultation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${appointment.queueNumber ?? 0}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.startTime,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (appointment.queueStatus == AppEnums.waiting) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartConsultation,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: AppTextStyles.buttonSmall,
                ),
                child: const Text('Start Consultation'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
