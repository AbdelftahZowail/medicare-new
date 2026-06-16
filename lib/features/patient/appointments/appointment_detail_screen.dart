import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_appointments_service.dart';
import '../services/patient_medical_history_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _service = PatientAppointmentsService();
  final _medicalHistoryService = PatientMedicalHistoryService();
  bool _loading = true;
  Appointment? _appointment;
  MedicalRecord? _medicalRecord;
  bool _loadingRecord = false;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    try {
      final appointment = await _service.getAppointmentDetail(widget.appointmentId);
      if (!mounted) return;
      setState(() {
        _appointment = appointment;
        _loading = false;
      });
      // If completed, also load the medical record for this appointment
      if (appointment.status == AppEnums.completed) {
        _loadMedicalRecord();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appointment = null;
        _loading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to load appointment details: ${e.toString()}'
                : 'Failed to load appointment details. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _loadMedicalRecord() async {
    setState(() => _loadingRecord = true);
    try {
      final patientId = await AuthService().getProfileId();
      if (patientId == null) return;
      final records = await _medicalHistoryService.getMedicalRecords(patientId);
      if (!mounted) return;
      // Find the record linked to this appointment
      final record = records.cast<MedicalRecord?>().firstWhere(
        (r) => r!.appointmentId == widget.appointmentId,
        orElse: () => null,
      );
      setState(() {
        _medicalRecord = record;
        _loadingRecord = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRecord = false);
    }
  }

  Future<void> _cancelAppointment() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter cancellation reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
                          ),
                      ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context, reasonController.text.trim());
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    reasonController.dispose();
    if (reason == null || reason.isEmpty) return;

    try {
      await _service.cancelAppointment(widget.appointmentId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
      _loadAppointment();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kEnableDebugTools
              ? 'Failed to cancel: ${e.toString()}'
              : 'Failed to cancel. Please try again.'),
        ),
      );
    }
  }

  void _rescheduleAppointment() {
    context.push(
      AppRoutes.patientBookAppointment,
      extra: {'doctorId': _appointment?.doctorId ?? 0},
    );
  }

  void _trackQueue() {
    if (_appointment?.queueNumber != null) {
      context.push('${AppRoutes.patientQueueTracker}/${widget.appointmentId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _appointment == null
                ? const Center(child: Text('Appointment not found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Header
                        _DoctorHeader(appointment: _appointment!),
                    const SizedBox(height: 20),

                    // Status Card
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
                          _DetailRow(
                            icon: Icons.info_outline,
                            label: 'Status',
                            value: _appointment!.statusText,
                            valueColor: _statusColor(_appointment!.status),
                          ),
                          const Divider(height: 24),
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: DateFormat('EEEE, MMM d, yyyy').format(_appointment!.appointmentDate),
                          ),
                          const Divider(height: 24),
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value: '${_appointment!.startTime}${_appointment!.endTime != null ? ' - ${_appointment!.endTime}' : ''}',
                          ),
                          if (_appointment!.queueNumber != null) ...[
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.confirmation_number,
                              label: 'Queue Number',
                              value: '#${_appointment!.queueNumber}',
                              valueColor: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Clinic Info
                    Text('Clinic Information', style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.local_hospital,
                            label: 'Clinic',
                            value: _appointment!.clinicName ?? 'N/A',
                          ),
                          if (_appointment!.clinicAddress != null) ...[
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.location_on,
                              label: 'Address',
                              value: _appointment!.clinicAddress!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Info
                    Text('Payment', style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.payment,
                            label: 'Method',
                            value: _appointment!.paymentMethodText,
                          ),
                          const Divider(height: 24),
                          _DetailRow(
                            icon: Icons.check_circle,
                            label: 'Payment Status',
                            value: _appointment!.paymentStatusText ?? 'N/A',
                            valueColor: _appointment!.paymentStatus == AppEnums.paymentPaid
                                ? AppColors.success
                                : _appointment!.paymentStatus == AppEnums.paymentPending
                                    ? AppColors.warning
                                    : _appointment!.paymentStatus == AppEnums.paymentRefunded
                                        ? AppColors.textSecondary
                                        : null,
                          ),
                          if (_appointment!.consultationFee != null) ...[
                            const Divider(height: 24),
                            _DetailRow(
                              icon: Icons.attach_money,
                              label: 'Consultation Fee',
                              value: '${_appointment!.consultationFee!.toStringAsFixed(2)} EGP',
                              valueColor: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Prescription (only for completed appointments)
                    if (_appointment!.status == AppEnums.completed) ...[
                      Text('Prescription', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      _loadingRecord
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : _medicalRecord != null
                              ? _PrescriptionCard(record: _medicalRecord!)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No prescription data available.',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    if (_appointment!.status == AppEnums.confirmed || _appointment!.status == AppEnums.pending) ...[
                      if (_appointment!.queueNumber != null)
                        AppButton(
                          text: 'Track Queue',
                          onPressed: _trackQueue,
                        ),
                      if (_appointment!.queueNumber != null)
                        const SizedBox(height: 12),
                      AppButton(
                        text: 'Reschedule',
                        isOutlined: true,
                        onPressed: _rescheduleAppointment,
                      ),
                      if (_appointment!.queueStatus == null ||
                          _appointment!.queueStatus == AppEnums.waiting) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Cancel Appointment',
                          isOutlined: true,
                          backgroundColor: AppColors.error,
                          onPressed: _cancelAppointment,
                        ),
                      ],
                    ],

                    if (_appointment!.status == AppEnums.completed) ...[
                      AppButton(
                        text: 'Submit Review',
                        onPressed: () => context.push(
                          AppRoutes.patientSubmitReview,
                          extra: {
                            'doctorId': _appointment!.doctorId,
                            'appointmentId': _appointment!.id,
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case AppEnums.pending:
        return AppColors.warning;
      case AppEnums.confirmed:
        return AppColors.info;
      case AppEnums.inProgress:
        return AppColors.primary;
      case AppEnums.completed:
        return AppColors.success;
      case AppEnums.cancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _DoctorHeader extends StatelessWidget {
  final Appointment appointment;
  const _DoctorHeader({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary100,
            backgroundImage: appointment.doctorProfileImageUrl != null
                ? NetworkImage(appointment.doctorProfileImageUrl!)
                : null,
            child: appointment.doctorProfileImageUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctorName,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.specialization,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final MedicalRecord record;
  const _PrescriptionCard({required this.record});

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
          // Diagnosis
          _DetailRow(
            icon: Icons.healing,
            label: 'Diagnosis',
            value: record.diagnosis,
          ),
          // Medications
          if (record.medications != null && record.medications!.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Medications',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ...record.medications!.map((med) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${med.dosage} - ${med.category}',
                          style: AppTextStyles.bodySmall,
                        ),
                        Text(
                          'Duration: ${med.duration}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
          // Instructions
          if (record.instructions != null && record.instructions!.isNotEmpty) ...[
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.assignment,
              label: 'Instructions',
              value: record.instructions!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
