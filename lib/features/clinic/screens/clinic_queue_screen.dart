import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../clinic/clinic_service.dart';

class ClinicQueueScreen extends StatefulWidget {
  final int doctorId;

  const ClinicQueueScreen({super.key, required this.doctorId});

  @override
  State<ClinicQueueScreen> createState() => _ClinicQueueScreenState();
}

class _ClinicQueueScreenState extends State<ClinicQueueScreen> {
  final _service = ClinicService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;
  int? _startingAppointmentId;

  Timer? _pollTimer;

  bool get _hasInProgressPatient =>
      _appointments.any((a) => a.queueStatus == AppEnums.inConsultation);

  Appointment? get _firstWaitingPatient {
    try {
      return _appointments.firstWhere((a) => a.queueStatus == AppEnums.waiting);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQueue();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _pollQueue();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQueue() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await _service.getClinicQueue(doctorId: widget.doctorId);
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _pollQueue() async {
    try {
      final data = await _service.getClinicQueue(doctorId: widget.doctorId);
      if (!mounted) return;
      setState(() {
        _appointments = data;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Queue Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadQueue,
                    child: _appointments.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _appointments.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildNextPatientHeader();
                              }
                              final appointment = _appointments[index - 1];
                              return _PatientQueueCard(
                                appointment: appointment,
                              );
                            },
                          ),
                  ),
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
              'Failed to load queue',
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
              onPressed: _loadQueue,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPatientHeader() {
    final next = _firstWaitingPatient;
    final canStart = next != null && !_hasInProgressPatient;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Patient',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      next != null
                          ? canStart
? 'Tap to start checkup for ${next!.displayName}'
                               : '${next!.displayName} is waiting — finish current patient first'
                          : 'No patients waiting',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: canStart ? AppColors.textSecondary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasInProgressPatient)
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'In Progress',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canStart ? _handleNextPatient : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                disabledBackgroundColor: AppColors.borderLight,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _startingAppointmentId != null
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : Text(canStart ? 'Start Checkup' : 'No Patient Available'),
            ),
          ),
        ],
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
              Icon(Icons.check_circle_outline, size: 64, color: AppColors.success.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Queue is empty',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'All patients have been served',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleNextPatient() {
    final next = _firstWaitingPatient;
    if (next != null) {
      _startCheckup(next);
    }
  }

  Future<void> _startCheckup(Appointment appointment) async {
    setState(() => _startingAppointmentId = appointment.id);
    try {
      await _service.startCheckup(appointment.id);
      if (mounted) {
        setState(() => _startingAppointmentId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkup started successfully')),
        );
        _loadQueue();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _startingAppointmentId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to start checkup: ${errorMessage(e)}'
                : 'Failed to start checkup. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _PatientQueueCard extends StatelessWidget {
  final Appointment appointment;

  const _PatientQueueCard({
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final queueNumber = appointment.queueNumber?.toString() ?? '--';
    final patientName = appointment.displayName;
    final status = appointment.statusText;
    final time = appointment.startTime.isNotEmpty ? appointment.startTime : '--:--';
    final isEmergency = appointment.isEmergency;

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'in progress':
      case 'inprogress':
        statusColor = AppColors.primary;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isEmergency ? AppColors.errorBg : AppColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  queueNumber,
                  style: AppTextStyles.heading2.copyWith(
                    color: isEmergency ? AppColors.error : AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patientName,
                            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isEmergency)
                          Container(
                            padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Emergency',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: $time',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          if (appointment.queueStatus == AppEnums.inConsultation) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.person_pin, size: 16, color: AppColors.primary),
                  ),
                  Text(
                    'In Consultation',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
