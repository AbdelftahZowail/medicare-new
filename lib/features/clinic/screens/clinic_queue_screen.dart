import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../clinic/clinic_service.dart';

class ClinicQueueScreen extends StatefulWidget {
  const ClinicQueueScreen({super.key});

  @override
  State<ClinicQueueScreen> createState() => _ClinicQueueScreenState();
}

class _ClinicQueueScreenState extends State<ClinicQueueScreen> {
  final _service = ClinicService();
  Map<String, dynamic>? _queueData;
  bool _isLoading = true;
  String? _error;
  int _selectedDoctorIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await _service.getClinicQueue();
      setState(() {
        _queueData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.clinicDashboard);
        break;
      case 1:
        context.go(AppRoutes.clinicDoctors);
        break;
      case 2:
        context.go(AppRoutes.clinicPayments);
        break;
      case 3:
        context.go(AppRoutes.clinicProfile);
        break;
    }
  }

  List<dynamic> get _doctorQueues {
    final queues = _queueData?['doctorQueues'] as List<dynamic>? ?? [];
    return queues;
  }

  Map<String, dynamic>? get _selectedDoctorQueue {
    if (_doctorQueues.isEmpty) return null;
    if (_selectedDoctorIndex >= _doctorQueues.length) return null;
    return _doctorQueues[_selectedDoctorIndex] as Map<String, dynamic>?;
  }

  List<dynamic> get _selectedPatients {
    final doctorQueue = _selectedDoctorQueue;
    if (doctorQueue == null) return [];
    return (doctorQueue['patients'] as List<dynamic>?) ?? [];
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
                : Column(
                    children: [
                      _buildDoctorSelector(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadQueue,
                          child: _selectedPatients.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                  itemCount: _selectedPatients.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final patient = _selectedPatients[index] as Map<String, dynamic>;
                                    return _PatientQueueCard(
                                      patient: patient,
                                      onStartCheckup: () => _startCheckup(patient),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        items: ClinicNavItems.items,
        onTap: _onNavTap,
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

  Widget _buildDoctorSelector() {
    if (_doctorQueues.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _doctorQueues.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final doctor = _doctorQueues[index] as Map<String, dynamic>;
          final name = doctor['doctorName'] ?? '';
          final isSelected = index == _selectedDoctorIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedDoctorIndex = index),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Future<void> _startCheckup(Map<String, dynamic> patient) async {
    final appointmentId = patient['appointmentId'] as int?;
    if (appointmentId == null) return;

    try {
      await _service.startCheckup(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkup started successfully')),
        );
        _loadQueue();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _PatientQueueCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onStartCheckup;

  const _PatientQueueCard({
    required this.patient,
    required this.onStartCheckup,
  });

  @override
  Widget build(BuildContext context) {
    final queueNumber = patient['queueNumber']?.toString() ?? '--';
    final patientName = patient['patientName'] ?? '';
    final status = patient['statusText'] ?? '';
    final time = patient['startTime'] ?? '--:--';
    final isEmergency = patient['isEmergency'] ?? false;

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
          if (status.toLowerCase() == 'waiting' || status.toLowerCase() == 'confirmed') ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartCheckup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Start Checkup'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
