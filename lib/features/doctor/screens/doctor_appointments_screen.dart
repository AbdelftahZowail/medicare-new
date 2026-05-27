import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../doctor/services/doctor_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final _service = DoctorService();
  DateTime _selectedDate = DateTime.now();
  int _statusFilter = -1; // -1 = all
  int _navIndex = 1;

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        context.go(AppRoutes.doctorDashboard);
        break;
      case 1:
        context.go(AppRoutes.doctorAppointments);
        break;
      case 2:
        context.go(AppRoutes.doctorCommunity);
        break;
      case 3:
        context.go(AppRoutes.doctorProfile);
        break;
    }
  }

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 3));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return AppColors.warning;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.info;
      case 3:
        return AppColors.success;
      case 4:
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  Color _statusBgColor(int status) {
    switch (status) {
      case 0:
        return AppColors.warningBg;
      case 1:
        return AppColors.primary50;
      case 2:
        return AppColors.infoBg;
      case 3:
        return AppColors.successBg;
      case 4:
        return AppColors.errorBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _FilterSheet(
                  selectedFilter: _statusFilter,
                  onSelect: (filter) {
                    setState(() => _statusFilter = filter);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar strip
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((date) {
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  final isToday = date.day == DateTime.now().day &&
                      date.month == DateTime.now().month &&
                      date.year == DateTime.now().year;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 44,
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekdayName(date.weekday),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : (isToday ? AppColors.primary : AppColors.textPrimary),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Appointment list
            Expanded(
              child: FutureBuilder(
                future: _service.getAppointments(date: _selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.error?.toString() ?? 'Failed to load appointments',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allAppointments = snapshot.data ?? [];
                  final appointments = _statusFilter == -1
                      ? allAppointments
                      : allAppointments
                          .where((a) => a.status == _statusFilter)
                          .toList();

                  if (appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments for this day',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      return _AppointmentCard(
                        appointment: appt,
                        statusColor: _statusColor(appt.status),
                        statusBgColor: _statusBgColor(appt.status),
                        onTap: () {
                          if (appt.status == AppEnums.confirmed ||
                              appt.status == AppEnums.inProgress) {
                            context.push(
                              '${AppRoutes.doctorConsultation}/${appt.id}',
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        items: DoctorNavItems.items,
        onTap: _onNavTap,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Color statusColor;
  final Color statusBgColor;
  final VoidCallback? onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.statusColor,
    required this.statusBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: appointment.doctorProfileImageUrl != null
                  ? NetworkImage(appointment.doctorProfileImageUrl!)
                  : const AssetImage(AssetPaths.patientProfile1) as ImageProvider,
              onBackgroundImageError: (_, __) {},
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
                    '${appointment.startTime} - ${appointment.specialization}',
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
                appointment.statusText,
                style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final int selectedFilter;
  final Function(int) onSelect;

  const _FilterSheet({
    required this.selectedFilter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (-1, 'All'),
      (AppEnums.pending, 'Pending'),
      (AppEnums.confirmed, 'Confirmed'),
      (AppEnums.inProgress, 'In Progress'),
      (AppEnums.completed, 'Completed'),
      (AppEnums.cancelled, 'Cancelled'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filter by Status', style: AppTextStyles.heading2),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isSelected = filter.$1 == selectedFilter;
              return ChoiceChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (_) => onSelect(filter.$1),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
