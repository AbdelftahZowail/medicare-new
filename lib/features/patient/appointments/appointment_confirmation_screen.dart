import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentConfirmationScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(appointment.appointmentDate);
    final timeLabel = _formatTime(appointment.startTime);
    final doctorName = appointment.doctorName.isNotEmpty
        ? appointment.doctorName
        : 'Your doctor';
    final clinicName = appointment.clinicName ?? 'Clinic';
    final clinicAddress = appointment.clinicAddress;
    final queueLabel = appointment.queueNumber != null
        ? '#${appointment.queueNumber}'
        : 'Pending';
    final bookerLabel = appointment.familyMemberName ?? appointment.patientName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.success, width: 3),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Appointment Booked!',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.success),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your appointment has been successfully scheduled. You will receive a confirmation shortly.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: dateLabel,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Time',
                              value: timeLabel,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.person,
                              label: 'Doctor',
                              value: doctorName,
                              subtitle: appointment.specialization,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.local_hospital,
                              label: 'Clinic',
                              value: clinicName,
                              subtitle: clinicAddress,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.confirmation_number,
                              label: 'Queue No',
                              value: queueLabel,
                            ),
                            if (bookerLabel.isNotEmpty) ...[
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: 'For',
                                value: bookerLabel,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'My Appointments',
                        onPressed: () => context.go(AppRoutes.patientAppointments),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Back to Home',
                        isOutlined: true,
                        onPressed: () => context.go(AppRoutes.patientHome),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return 'Time TBD';
    final parts = raw.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0
          ? 12
          : (hour > 12 ? hour - 12 : hour);
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    }
    return raw;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600)),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
