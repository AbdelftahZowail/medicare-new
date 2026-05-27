import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Checkmark
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

              // Appointment Summary Card
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
                    _InfoRow(icon: Icons.calendar_today, label: 'Date', value: 'Tomorrow, 10:00 AM'),
                    const Divider(height: 24),
                    _InfoRow(icon: Icons.person, label: 'Doctor', value: 'Dr. Ahmed Hassan'),
                    const Divider(height: 24),
                    _InfoRow(icon: Icons.local_hospital, label: 'Clinic', value: 'Medicare Clinic'),
                    const Divider(height: 24),
                    _InfoRow(icon: Icons.confirmation_number, label: 'Queue No', value: 'Pending'),
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
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            ],
          ),
        ),
      ],
    );
  }
}
