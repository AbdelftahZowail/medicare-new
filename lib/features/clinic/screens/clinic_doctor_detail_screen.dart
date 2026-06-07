import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/models/doctor_models.dart';
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
  DoctorProfile? _doctor;
  List<DoctorSchedule> _schedules = [];
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
      final doctor = await _service.getClinicDoctorDetail(widget.doctorId);
      final schedules = await _service.getDoctorSchedules(widget.doctorId);
      setState(() {
        _doctor = doctor;
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditFeeStatusDialog() async {
    final feeController = TextEditingController(
      text: (_doctor?.consultationFee ?? 0.0).toString(),
    );
    bool isAvailable = _doctor?.isAvailable ?? false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Fee & Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation Fee',
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Available'),
                    selected: isAvailable,
                    onSelected: (v) => setDialogState(() => isAvailable = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Unavailable'),
                    selected: !isAvailable,
                    onSelected: (v) => setDialogState(() => isAvailable = false),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final fee = double.tryParse(feeController.text.trim()) ?? _doctor?.consultationFee ?? 0.0;

    try {
      await _service.updateClinicDoctor(widget.doctorId, {
        'consultationFee': fee,
        'isAvailable': isAvailable,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor updated successfully')),
        );
        _loadDoctor();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage(e))),
        );
      }
    }
  }

  Future<void> _removeDoctor() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Doctor'),
        content: Text('Are you sure you want to remove ${_doctor?.fullName ?? 'this doctor'} from your clinic?'),
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
          SnackBar(content: Text(errorMessage(e))),
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
                if (value == 'fees') {
                  _showEditFeeStatusDialog();
                } else if (value == 'edit') {
                  context.push('${AppRoutes.clinicManageSchedule}/${widget.doctorId}');
                } else if (value == 'remove') {
                  _removeDoctor();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'fees',
                  child: Row(
                    children: [
                      Icon(Icons.attach_money, size: 20),
                      SizedBox(width: 12),
                      Text('Edit Fee & Status'),
                    ],
                  ),
                ),
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
    final name = _doctor?.fullName ?? '';
    final specialization = _doctor?.specialization ?? '';
    final imageUrl = _doctor?.profileImageUrl;
    final rating = _doctor?.averageRating ?? 0.0;
    final reviews = _doctor?.totalReviews ?? 0;
    final experience = _doctor?.yearsOfExperience;

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
          if (experience != null) ...[
            const SizedBox(height: 4),
            Text(
              '$experience years of experience',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
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
    final fee = _doctor?.consultationFee ?? 0.0;
    final isAvailable = _doctor?.isAvailable ?? false;
    final degree = _doctor?.degree;
    final university = _doctor?.university;
    final graduationYear = _doctor?.graduationYear;
    final boardCert = _doctor?.boardCertification;
    final bio = _doctor?.bio;
    final languages = _doctor?.languages ?? [];

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
          if (degree != null && degree.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.school,
              label: 'Degree',
              value: degree,
              iconColor: AppColors.primary,
            ),
          ],
          if (university != null && university.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.account_balance,
              label: 'University',
              value: university,
              iconColor: AppColors.primary,
            ),
          ],
          if (graduationYear != null) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Graduation Year',
              value: graduationYear.toString(),
              iconColor: AppColors.primary,
            ),
          ],
          if (boardCert != null && boardCert.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.verified,
              label: 'Board Certification',
              value: boardCert,
              iconColor: AppColors.success,
            ),
          ],
          if (languages.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.language,
              label: 'Languages',
              value: languages.join(', '),
              iconColor: AppColors.info,
            ),
          ],
          if (bio != null && bio.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(bio, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    // Group schedules by day and merge time ranges
    final daySchedules = <int, List<DoctorSchedule>>{};
    for (final s in _schedules) {
      daySchedules.putIfAbsent(s.dayOfWeek, () => []).add(s);
    }

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
            children: List.generate(7, (dayIndex) {
              final slots = daySchedules[dayIndex] ?? [];
              final isActive = slots.isNotEmpty;
              final timeText = isActive
                  ? slots.map((s) => '${s.startTime} - ${s.endTime}').join(', ')
                  : 'Closed';

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
                            dayNames[dayIndex],
                            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeText,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
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
