import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/widgets/fcm_token_debug_widget.dart';
import '../../clinic/clinic_service.dart';

class ClinicDashboardScreen extends StatefulWidget {
  const ClinicDashboardScreen({super.key});

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  final _service = ClinicService();
  Map<String, dynamic>? _dashboardData;
  List<Appointment> _recentAppointments = [];
  List<DoctorListItem> _doctors = [];
  int? _selectedDoctorId;
  bool _isLoading = true;
  bool _isLoadingDoctors = true;
  bool _isLoadingQueue = false;
  String? _error;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _pollDashboard();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() => _isLoadingDoctors = true);
      final doctors = await _service.getClinicDoctors();
      setState(() {
        _doctors = doctors;
        _isLoadingDoctors = false;
        if (doctors.isNotEmpty) {
          _selectedDoctorId = doctors.first.id;
          _loadDashboard();
        } else {
          _isLoading = false;
          _error = 'No doctors registered in this clinic';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingDoctors = false;
        _isLoading = false;
        _error = errorMessage(e);
      });
    }
  }

  Future<void> _loadDashboard() async {
    if (_selectedDoctorId == null) return;
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await _service.getClinicDashboard(doctorId: _selectedDoctorId!);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
    // Load queue list for recent appointments section
    _loadQueueForRecent();
  }

  Future<void> _pollDashboard() async {
    if (_selectedDoctorId == null) return;
    try {
      final data = await _service.getClinicDashboard(doctorId: _selectedDoctorId!);
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorMessage(e));
    }
    _loadQueueForRecent();
  }

  Future<void> _loadQueueForRecent() async {
    if (_selectedDoctorId == null) return;
    try {
      setState(() => _isLoadingQueue = true);
      final queue = await _service.getClinicQueue(doctorId: _selectedDoctorId!);
      setState(() {
        _recentAppointments = queue;
        _isLoadingQueue = false;
      });
    } catch (_) {
      setState(() => _isLoadingQueue = false);
    }
  }

  void _onDoctorChanged(int doctorId) {
    setState(() => _selectedDoctorId = doctorId);
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboardData ?? <String, dynamic>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FcmTokenDebugWidget(),
                ),
                const SizedBox(height: 8),
                _buildDoctorSelector(),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 20),
                _isLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _error != null
                        ? (_doctors.isEmpty
                            ? _buildNoDoctors()
                            : _buildError())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsCards(dashboard),
                              const SizedBox(height: 24),
                              _buildQuickActions(),
                              const SizedBox(height: 24),
                              _buildRecentAppointments(),
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.local_hospital, color: AppColors.textOnPrimary, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clinic', style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
              Text(
                'Dashboard',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.clinicNotifications),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(Icons.notifications_none, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSelector() {
    if (_isLoadingDoctors) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_doctors.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No doctors registered. Scan a doctor QR to add one.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final selectedDoctor = _doctors.firstWhere(
      (d) => d.id == _selectedDoctorId,
      orElse: () => _doctors.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDoctorId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: _doctors.map((doctor) {
            return DropdownMenuItem<int>(
              value: doctor.id,
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        doctor.fullName,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        doctor.specialization,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) _onDoctorChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dateStr = '${_monthName(now.month)} ${now.day}, ${now.year}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.textOnPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Today\'s Overview',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary100),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Live',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
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
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDoctors() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.person_add_disabled, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No doctors registered yet',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a doctor\'s QR code to start using the dashboard.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.clinicScanQr),
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scan Doctor QR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> data) {
    final paidCount = data['paidCount'] ?? 0;
    final walkInCount = data['walkInCount'] ?? 0;
    final revenue = data['todayRevenueAmount'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_outlined,
            iconColor: AppColors.primary,
            iconBg: AppColors.primary100,
            value: paidCount.toString(),
            label: 'Paid Patients',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.person_add_alt_outlined,
            iconColor: AppColors.success,
            iconBg: AppColors.successBg,
            value: walkInCount.toString(),
            label: 'Walk-ins',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningBg,
            value: '\$${(revenue as num).toStringAsFixed(0)}',
            label: 'Revenue',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.person_add,
                label: 'Add Walk-in',
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.clinicWalkInBooking),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.queue_play_next,
                label: 'View Queue',
                color: AppColors.success,
                onTap: () => context.push(
                  '${AppRoutes.clinicQueue}?doctorId=$_selectedDoctorId',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAppointments() {
    final appointments = _recentAppointments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Appointments', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No appointments today',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length.clamp(0, 5),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _AppointmentListItem(
                patientName: appt.displayName,
                doctorName: appt.doctorName,
                time: appt.startTime,
                status: appt.statusText,
                isPaid: appt.isPaid,
                patientProfileImageUrl: appt.patientProfileImageUrl,
              );
            },
          ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading1.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }
}

class _AppointmentListItem extends StatelessWidget {
  final String patientName;
  final String doctorName;
  final String time;
  final String status;
  final bool isPaid;
  final String? patientProfileImageUrl;

  const _AppointmentListItem({
    required this.patientName,
    required this.doctorName,
    required this.time,
    required this.status,
    required this.isPaid,
    this.patientProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'in progress':
        statusColor = AppColors.primary;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary100,
            backgroundImage: patientProfileImageUrl?.isNotEmpty == true
                ? NetworkImage(patientProfileImageUrl!)
                : null,
            child: patientProfileImageUrl?.isNotEmpty != true
                ? const Icon(Icons.person, color: AppColors.primary, size: 22)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  'Dr. $doctorName · $time',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
              const SizedBox(height: 4),
              if (isPaid)
                Text(
                  'Paid',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                )
              else
                Text(
                  'Unpaid',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
