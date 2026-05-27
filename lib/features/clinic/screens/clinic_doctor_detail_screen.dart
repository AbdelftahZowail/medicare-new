import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../clinic/clinic_service.dart';

class ClinicDoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const ClinicDoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<ClinicDoctorDetailScreen> createState() => _ClinicDoctorDetailScreenState();
}

class _ClinicDoctorDetailScreenState extends State<ClinicDoctorDetailScreen> {
  final _service = ClinicService();
  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      // Using scan endpoint as a proxy for doctor detail, or we could use public doctor detail
      // For now, we'll simulate with the doctors list or use a direct endpoint
      final doctors = await _service.getClinicDoctors();
      final index = doctors.indexWhere((d) => d.id == widget.doctorId);
      if (index != -1) {
        final doctor = doctors[index];
        setState(() {
          _doctorData = {
            'id': doctor.id,
            'fullName': doctor.fullName,
            'specialization': doctor.specialization,
            'profileImageUrl': doctor.profileImageUrl,
            'consultationFee': doctor.consultationFee,
            'averageRating': doctor.averageRating,
            'totalReviews': doctor.totalReviews,
            'isAvailable': doctor.isAvailable,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Doctor not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeDoctor() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Doctor'),
        content: Text('Are you sure you want to remove ${_doctorData?['fullName'] ?? 'this doctor'} from your clinic?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.removeDoctorFromClinic(widget.doctorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor removed successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Details'),
        actions: [
          if (!_isLoading && _error == null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  context.push('${AppRoutes.clinicManageSchedule}/${widget.doctorId}');
                } else if (value == 'remove') {
                  _removeDoctor();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_calendar, size: 20),
                      SizedBox(width: 12),
                      Text('Manage Schedule'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 20, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Remove from Clinic', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      children: [
                        _buildDoctorHeader(),
                        const SizedBox(height: 24),
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                        _buildScheduleSection(),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Manage Schedule',
                          icon: Icons.edit_calendar,
                          onPressed: () => context.push('${AppRoutes.clinicManageSchedule}/${widget.doctorId}'),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Remove from Clinic',
                          isOutlined: true,
                          backgroundColor: AppColors.error,
                          textColor: AppColors.error,
                          onPressed: _removeDoctor,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Unknown error',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDoctor,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader() {
    final name = _doctorData?['fullName'] ?? '';
    final specialization = _doctorData?['specialization'] ?? '';
    final imageUrl = _doctorData?['profileImageUrl'] as String?;
    final rating = (_doctorData?['averageRating'] as num?)?.toDouble() ?? 0.0;
    final reviews = _doctorData?['totalReviews'] ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage(AssetPaths.drJamesWilson),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            specialization,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: AppColors.warning, size: 20),
              const SizedBox(width: 6),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Text(
                '($reviews reviews)',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final fee = (_doctorData?['consultationFee'] as num?)?.toDouble() ?? 0.0;
    final isAvailable = _doctorData?['isAvailable'] ?? false;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Consultation Fee',
            value: '\$${fee.toStringAsFixed(2)}',
            iconColor: AppColors.primary,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.schedule,
            label: 'Status',
            value: isAvailable ? 'Available' : 'Unavailable',
            valueColor: isAvailable ? AppColors.success : AppColors.error,
            iconColor: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    // Mock schedule data - in real app would come from API
    final schedule = [
      {'day': 'Saturday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Sunday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Monday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Tuesday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Wednesday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Thursday', 'time': '09:00 AM - 05:00 PM', 'isActive': true},
      {'day': 'Friday', 'time': 'Closed', 'isActive': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule at this Clinic', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: schedule.map((s) {
              final isActive = s['isActive'] as bool;
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary100 : AppColors.errorBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive ? Icons.check : Icons.close,
                        color: isActive ? AppColors.primary : AppColors.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['day'] as String,
                            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['time'] as String,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
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
