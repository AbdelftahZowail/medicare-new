import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../data/doctor_service.dart';
import '../services/patient_appointments_service.dart';
import '../services/patient_family_members_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  final int doctorId;
  const BookAppointmentScreen({super.key, required this.doctorId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _doctorService = DoctorService();
  final _appointmentsService = PatientAppointmentsService();
  final _familyService = PatientFamilyMembersService();

  bool _loading = true;
  bool _booking = false;
  bool _slotsLoading = false;
  DoctorProfile? _doctor;
  List<FamilyMember> _familyMembers = [];

  DateTime? _selectedDate;
  String? _selectedTime;
  bool _forFamilyMember = false;
  FamilyMember? _selectedFamilyMember;

  List<AvailableSlot> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doctor = await _doctorService.getDoctorProfile(widget.doctorId);
      final familyMembers = await _familyService.getFamilyMembers();
      if (!mounted) return;
      setState(() {
        _doctor = doctor;
        _familyMembers = familyMembers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _booking = true);

    final request = BookAppointmentRequest(
      doctorId: widget.doctorId,
      appointmentDate: _selectedDate!,
      startTime: _selectedTime!,
      familyMemberId: _forFamilyMember ? _selectedFamilyMember?.id : null,
    );

    try {
      final appointment = await _appointmentsService.bookAppointment(request);
      if (!mounted) return;
      context.go(
        AppRoutes.patientAppointmentConfirmation,
        extra: appointment,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _slotsLoading = true;
      _selectedDate = date;
      _selectedTime = null;
    });
    try {
      final slots = await _doctorService.getAvailableSlots(
        doctorId: widget.doctorId,
        date: date,
      );
      if (!mounted) return;
      setState(() {
        _availableSlots = slots.where((s) => s.isAvailable).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Info Summary
                    _DoctorInfoCard(
                      doctor: _doctor,
                      familyMember: _forFamilyMember ? _selectedFamilyMember : null,
                    ),
                    const SizedBox(height: 20),

                    // Inline Calendar
                    Text('Select Date', style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 14,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
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

                    // Time Selection
                    if (_selectedDate != null) ...[
                      Row(
                        children: [
                          Text('Select Time', style: AppTextStyles.heading3),
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
                      const SizedBox(height: 20),
                    ],

                    // Family Member Toggle
                    if (_familyMembers.isNotEmpty) ...[
                      Row(
                        children: [
                          Text('Book for Family Member', style: AppTextStyles.heading3),
                          const Spacer(),
                          Switch(
                            value: _forFamilyMember,
                            onChanged: (v) => setState(() {
                              _forFamilyMember = v;
                              if (!v) _selectedFamilyMember = null;
                            }),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      if (_forFamilyMember) ...[
                        const SizedBox(height: 10),
                        ..._familyMembers.map((member) {
                          final isSelected = _selectedFamilyMember?.id == member.id;
                          return InkWell(
                            onTap: () => setState(() => _selectedFamilyMember = member),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primary100,
                                    child: Text(
                                      member.name.isNotEmpty ? member.name[0] : '',
                                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(member.name, style: AppTextStyles.labelLarge),
                                        Text(
                                          _relationText(member.relation),
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 20),
                    ],

                    // Booking Summary
                    Text('Booking Summary', style: AppTextStyles.heading3),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Doctor',
                            value: _doctor?.fullName ?? '',
                          ),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Specialization',
                            value: _doctor?.specialization ?? '',
                          ),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Date',
                            value: _selectedDate == null
                                ? 'Not selected'
                                : DateFormat('MMM d, yyyy').format(_selectedDate!),
                          ),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Time',
                            value: _selectedTime ?? 'Not selected',
                          ),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Fee',
                            value: '${(_doctor?.consultationFee ?? 0).toStringAsFixed(0)} EGP',
                            valueColor: AppColors.primary,
                          ),
                          if (_forFamilyMember && _selectedFamilyMember != null) ...[
                            const Divider(height: 20),
                            _SummaryRow(
                              label: 'For',
                              value: _selectedFamilyMember!.name,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'Confirm Appointment',
                      isLoading: _booking,
                      onPressed: _bookAppointment,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }

  String _relationText(int relation) {
    switch (relation) {
      case 0:
        return 'Parent';
      case 1:
        return 'Child';
      case 2:
        return 'Spouse';
      case 3:
        return 'Sibling';
      default:
        return 'Other';
    }
  }
}

class _DoctorInfoCard extends StatelessWidget {
  final DoctorProfile? doctor;
  final FamilyMember? familyMember;
  const _DoctorInfoCard({required this.doctor, this.familyMember});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary100,
            backgroundImage: doctor?.profileImageUrl != null
                ? NetworkImage(doctor!.profileImageUrl!)
                : null,
            child: doctor?.profileImageUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor?.fullName ?? '',
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor?.specialization ?? '',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${(doctor?.averageRating ?? 0).toStringAsFixed(1)}',
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${doctor?.totalReviews ?? 0} reviews)',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                if (familyMember != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.family_restroom, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Booking for: ${familyMember!.name}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
