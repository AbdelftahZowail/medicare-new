import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../data/doctor_service.dart';

class DoctorProfileScreen extends StatefulWidget {
  final int doctorId;
  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _service = DoctorService();

  bool _loading = true;
  bool _slotsLoading = false;
  DoctorProfile? _doctor;
  List<DoctorSchedule> _schedules = [];
  DateTime? _selectedDate;
  List<AvailableSlot> _availableSlots = [];
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _service.getDoctorProfile(widget.doctorId),
      _service.getDoctorSchedules(widget.doctorId),
    ]);
    if (!mounted) return;
    setState(() {
      _doctor = results[0] as DoctorProfile;
      _schedules = results[1] as List<DoctorSchedule>;
      _loading = false;
    });
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _slotsLoading = true;
      _selectedDate = date;
      _selectedTime = null;
    });
    try {
      final slots = await _service.getAvailableSlots(
        doctorId: widget.doctorId,
        date: date,
      );
      if (!mounted) return;
      setState(() {
        _availableSlots = slots.where((s) {
          if (!s.isAvailable) return false;
          // If today, filter out slots whose time has already passed
          final now = DateTime.now();
          if (_selectedDate!.year == now.year &&
              _selectedDate!.month == now.month &&
              _selectedDate!.day == now.day) {
            final parts = s.time.split(':');
            if (parts.length >= 2) {
              final hour = int.tryParse(parts[0]) ?? 0;
              final minute = int.tryParse(parts[1]) ?? 0;
              final slotDt = DateTime(now.year, now.month, now.day, hour, minute);
              if (slotDt.isBefore(now)) return false;
            }
          }
          return true;
        }).toList();
        _slotsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _availableSlots = [];
        _slotsLoading = false;
      });
    }
  }

  /// Days in the next 14 days where the doctor has a schedule.
  /// Falls back to all 14 days when no schedule data is available.
  List<DateTime> get _availableDates {
    final now = DateTime.now();
    final allDays = List.generate(14, (i) => now.add(Duration(days: i)));
    if (_schedules.isEmpty) return allDays;
    final scheduledDays = _schedules.map((s) => s.dayOfWeek).toSet();
    // DateTime.weekday: 1=Mon..7=Sun. DoctorSchedule.dayOfWeek: 0=Sun..6=Sat.
    return allDays.where((d) => scheduledDays.contains(d.weekday % 7)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary100,
                          backgroundImage: _doctor?.profileImageUrl != null && _doctor!.profileImageUrl!.isNotEmpty
                              ? NetworkImage(_doctor!.profileImageUrl!)
                              : null,
                          child: (_doctor?.profileImageUrl == null || _doctor!.profileImageUrl!.isEmpty)
                              ? const Icon(Icons.person, color: AppColors.primary, size: 36)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctor?.fullName ?? '',
                                style: AppTextStyles.heading2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _doctor?.specialization ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(_doctor?.averageRating ?? 0).toStringAsFixed(1)}',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${_doctor?.totalReviews ?? 0} reviews)',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.work_outline,
                          label: 'Experience',
                          value: '${_doctor?.yearsOfExperience ?? 0}+ years',
                          color: AppColors.primary,
                          bgColor: AppColors.primary50,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.people_outline,
                          label: 'Patients',
                          value: '${_doctor?.totalReviews ?? 0}+',
                          color: AppColors.success,
                          bgColor: AppColors.successBg,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          icon: Icons.star_outline,
                          label: 'Rating',
                          value: '${(_doctor?.averageRating ?? 0).toStringAsFixed(1)}',
                          color: AppColors.warning,
                          bgColor: AppColors.warningBg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fee Card
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Consultation Fee', style: AppTextStyles.bodyLarge),
                          const Spacer(),
                          Text(
                            '${(_doctor?.consultationFee ?? 0).toStringAsFixed(0)} EGP',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bio
                    if (_doctor?.bio != null && _doctor!.bio!.isNotEmpty) ...[
                      Text('About', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          _doctor!.bio!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Languages
                    if (_doctor?.languages.isNotEmpty ?? false) ...[
                      Text('Languages', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _doctor!.languages.map((lang) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              lang,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Education & Certification
                    if ((_doctor?.degree != null && _doctor!.degree!.isNotEmpty) ||
                        (_doctor?.university != null && _doctor!.university!.isNotEmpty) ||
                        (_doctor?.boardCertification != null && _doctor!.boardCertification!.isNotEmpty)) ...[
                      Text('Education & Certification', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_doctor?.degree != null && _doctor!.degree!.isNotEmpty) ...[
                              _InfoRow(icon: Icons.school_outlined, label: 'Degree', value: _doctor!.degree!),
                              const SizedBox(height: 12),
                            ],
                            if (_doctor?.university != null && _doctor!.university!.isNotEmpty) ...[
                              _InfoRow(icon: Icons.account_balance_outlined, label: 'University', value: _doctor!.university!),
                              const SizedBox(height: 12),
                            ],
                            if (_doctor?.graduationYear != null) ...[
                              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Graduation Year', value: _doctor!.graduationYear.toString()),
                              const SizedBox(height: 12),
                            ],
                            if (_doctor?.boardCertification != null && _doctor!.boardCertification!.isNotEmpty)
                              _InfoRow(icon: Icons.verified_outlined, label: 'Board Certification', value: _doctor!.boardCertification!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Associated Clinics
                    if (_doctor?.associatedClinics.isNotEmpty ?? false) ...[
                      Text('Associated Clinics', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _doctor!.associatedClinics.map((clinic) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_hospital, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    clinic,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Inline Calendar
                    Text('Select Date', style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    if (_availableDates.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Center(
                          child: Text(
                            'No available days in the next 14 days',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableDates.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final date = _availableDates[index];
                            final isSelected = _selectedDate != null &&
                                date.year == _selectedDate!.year &&
                                date.month == _selectedDate!.month &&
                                date.day == _selectedDate!.day;
                            return GestureDetector(
                              onTap: () => _loadSlots(date),
                              child: Container(
                                width: 60,
                                padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${date.day}',
                                      style: AppTextStyles.heading3.copyWith(
                                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Available Slots
                    if (_selectedDate != null) ...[
                      Row(
                        children: [
                          Text('Available Slots', style: AppTextStyles.heading3),
                          const Spacer(),
                          if (_slotsLoading)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (!_slotsLoading && _availableSlots.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Center(
                            child: Text(
                              'No available slots for this date',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableSlots.map((slot) {
                            final isSelected = _selectedTime == slot.time;
                            return ChoiceChip(
                              label: Text(slot.time),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedTime = slot.time),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Book Appointment CTA
                    AppButton(
                      text: 'Book Appointment',
                      onPressed: () {
                        context.push(
                          AppRoutes.patientBookAppointment,
                          extra: {
                            'doctorId': widget.doctorId,
                            if (_selectedDate != null)
                              'selectedDate': _selectedDate,
                            if (_selectedTime != null)
                              'selectedTime': _selectedTime,
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'My Appointments',
                      isOutlined: true,
                      onPressed: () => context.go(AppRoutes.patientAppointments),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.heading4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
