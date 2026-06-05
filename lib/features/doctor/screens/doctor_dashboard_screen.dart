import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../doctor/services/doctor_service.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _service = DoctorService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder(
          future: _service.getDashboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error?.toString() ?? 'Failed to load dashboard',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    onNotificationsTap: () =>
                        context.push(AppRoutes.doctorNotifications),
                  ),
                  const SizedBox(height: 20),
                  _TodayAppointmentsCard(
                    total: data['totalAppointments'] as int? ?? 0,
                    newPatients: data['newPatientsCount'] as int? ?? 0,
                    followUps: data['followUpsCount'] as int? ?? 0,
                    walkIns: data['walkInsCount'] as int? ?? 0,
                    online: data['onlineCount'] as int? ?? 0,
                  ),
                  const SizedBox(height: 16),
                  _EarningsCard(
                    amount: (data['todayEarnings'] as num?)?.toDouble() ?? 0,
                  ),
                  const SizedBox(height: 16),
                  _ScheduleButton(
                    onTap: () => context.go(AppRoutes.doctorAppointments),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final profile = await DoctorService().getProfile();
                          if (mounted) {
                            context.push(
                              AppRoutes.doctorSchedule,
                              extra: {'doctorId': profile.id},
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to load schedule: ${errorMessage(e)}')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: const Text('Manage My Schedule'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Queue Summary',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QueueSummaryCard(
                    waiting: data['waitingCount'] as int? ?? 0,
                    withDoctor: data['withDoctorCount'] as int? ?? 0,
                    completed: data['completedCount'] as int? ?? 0,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(AssetPaths.doctorJulian),
        ),
        const SizedBox(width: 10),
        Text('Medicare', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, color: AppColors.textOnPrimary, size: 22),
          ),
        ),
      ],
    );
  }
}

class _TodayAppointmentsCard extends StatelessWidget {
  final int total;
  final int newPatients;
  final int followUps;
  final int walkIns;
  final int online;

  const _TodayAppointmentsCard({
    required this.total,
    required this.newPatients,
    required this.followUps,
    required this.walkIns,
    required this.online,
  });

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
          Text('Today\'s Appointments', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(label: 'New Visit', value: newPatients, color: AppColors.primary50, icon: Icons.person_add_alt_1),
              const SizedBox(width: 8),
              _StatChip(label: 'Follow Up', value: followUps, color: AppColors.successBg, icon: Icons.repeat),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(label: 'Walk-in', value: walkIns, color: AppColors.warningBg, icon: Icons.directions_walk),
              const SizedBox(width: 8),
              _StatChip(label: 'Online', value: online, color: AppColors.infoBg, icon: Icons.videocam_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final double amount;

  const _EarningsCard({required this.amount});

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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Earnings', style: AppTextStyles.labelMedium),
              const SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(0)}',
                style: AppTextStyles.heading1.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ScheduleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScheduleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_today, size: 18),
        label: const Text('View Today\'s Schedule'),
      ),
    );
  }
}

class _QueueSummaryCard extends StatelessWidget {
  final int waiting;
  final int withDoctor;
  final int completed;

  const _QueueSummaryCard({
    required this.waiting,
    required this.withDoctor,
    required this.completed,
  });

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
        children: [
          _QueueRow(
            label: 'Waiting',
            value: waiting,
            color: AppColors.warning,
            bgColor: AppColors.warningBg,
            icon: Icons.hourglass_top,
          ),
          const Divider(height: 16),
          _QueueRow(
            label: 'With Doctor',
            value: withDoctor,
            color: AppColors.primary,
            bgColor: AppColors.primary50,
            icon: Icons.local_hospital,
          ),
          const Divider(height: 16),
          _QueueRow(
            label: 'Completed',
            value: completed,
            color: AppColors.success,
            bgColor: AppColors.successBg,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _QueueRow({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyLarge),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toString(),
            style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
