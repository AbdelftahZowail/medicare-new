import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_appointments_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _service = PatientAppointmentsService();
  bool _loading = true;
  Appointment? _appointment;

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appointment = null;
        _loading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load appointment details. Please try again.')),
        );
      }
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.cancelAppointment(widget.appointmentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
      _loadAppointment();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')),
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
                            label: 'Paid',
                            value: _appointment!.isPaid ? 'Yes' : 'No',
                            valueColor: _appointment!.isPaid ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Cancel Appointment',
                        isOutlined: true,
                        backgroundColor: AppColors.error,
                        onPressed: _cancelAppointment,
                      ),
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
