import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../services/patient_appointments_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _service = PatientAppointmentsService();
  late TabController _tabController;

  bool _loading = true;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);

    String? filter;
    switch (_tabController.index) {
      case 0:
        filter = 'upcoming';
        break;
      case 1:
        filter = 'completed';
        break;
      case 2:
        filter = 'cancelled';
        break;
    }

    try {
      final appointments = await _service.getMyAppointments(filter: filter);
      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appointments = [];
        _loading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load appointments. Please try again.')),
        );
      }
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.patientHome);
        break;
      case 1:
        // Already on appointments
        break;
      case 2:
        context.go(AppRoutes.patientCommunity);
        break;
      case 3:
        context.go(AppRoutes.patientBrowseDoctors);
        break;
      case 4:
        context.go(AppRoutes.patientProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('upcoming'),
                _buildTabContent('completed'),
                _buildTabContent('cancelled'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              text: 'Book New Appointment',
              onPressed: () => context.push(AppRoutes.patientSpecializations),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AppointmentsBottomNav(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildTabContent(String filter) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _appointments.where((a) {
      if (filter == 'upcoming') {
        return a.status == AppEnums.pending || a.status == AppEnums.confirmed || a.status == AppEnums.inProgress;
      } else if (filter == 'completed') {
        return a.status == AppEnums.completed;
      } else {
        return a.status == AppEnums.cancelled || a.status == AppEnums.noShow;
      }
    }).toList();

    if (filtered.isEmpty) {
      return _EmptyState(filter: filter);
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appointment = filtered[index];
          return _AppointmentCard(
            appointment: appointment,
            onTap: () => context.push('${AppRoutes.patientAppointmentDetail}/${appointment.id}'),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const _AppointmentCard({required this.appointment, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary100,
                  backgroundImage: AssetImage(
                    [
                      AssetPaths.doctorPhoto1,
                      AssetPaths.doctorPhoto2,
                      AssetPaths.doctorPhoto3,
                      AssetPaths.doctorPhoto4,
                    ][(appointment.doctorId - 1) % 4],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.specialization,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: appointment.status, statusText: appointment.statusText),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(appointment.appointmentDate),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  appointment.startTime,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (appointment.queueNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.confirmation_number, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Queue #${appointment.queueNumber}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status;
  final String statusText;

  const _StatusBadge({required this.status, required this.statusText});

  Color get _bgColor {
    switch (status) {
      case AppEnums.pending:
        return AppColors.warningBg;
      case AppEnums.confirmed:
        return AppColors.infoBg;
      case AppEnums.inProgress:
        return AppColors.primary100;
      case AppEnums.completed:
        return AppColors.successBg;
      case AppEnums.cancelled:
        return AppColors.errorBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color get _fgColor {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelSmall.copyWith(
          color: _fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                AssetPaths.emptyAppointments,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No ${filter} appointments',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any ${filter} appointments at the moment.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _AppointmentsBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
      _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today, label: 'Appointments'),
      _NavItemData(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'AI Bot'),
      _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Nearby'),
      _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
}
