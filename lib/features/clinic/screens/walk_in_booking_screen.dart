import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../clinic/clinic_service.dart';

class WalkInBookingScreen extends StatefulWidget {
  const WalkInBookingScreen({super.key});

  @override
  State<WalkInBookingScreen> createState() => _WalkInBookingScreenState();
}

class _WalkInBookingScreenState extends State<WalkInBookingScreen> {
  final _service = ClinicService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  bool _isEmergency = false;
  int? _selectedGender;
  int? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  List<dynamic> _doctors = [];
  bool _doctorsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _service.getClinicDoctors();
      setState(() {
        _doctors = doctors;
        _doctorsLoading = false;
      });
    } catch (e) {
      setState(() => _doctorsLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final data = {
        'doctorId': _selectedDoctorId,
        'appointmentDate': _selectedDate.toIso8601String().split('T')[0],
        'startTime': timeStr,
        'offlinePatientName': _nameController.text.trim(),
        'offlinePatientPhone': _phoneController.text.trim(),
        'offlinePatientAge': int.tryParse(_ageController.text) ?? 0,
        'offlinePatientGender': _selectedGender ?? 0,
        'isEmergency': _isEmergency,
        'isPaid': false,
        'paymentMethod': 0,
      };

      await _service.bookWalkInAppointment(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Walk-in booked successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to book appointment: ${errorMessage(e)}'
                : 'Failed to book appointment. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Walk-in Patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Details', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Patient Name',
                  hint: 'Enter full name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Phone is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Age',
                        hint: 'Years',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender', style: AppTextStyles.labelLarge),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded: true,
                                value: _selectedGender,
                                hint: Text('Select', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                                items: const [
                                  DropdownMenuItem(value: 0, child: Text('Male')),
                                  DropdownMenuItem(value: 1, child: Text('Female')),
                                ],
                                onChanged: (value) => setState(() => _selectedGender = value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Appointment Details', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                _buildDoctorSelector(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePicker(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Case',
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mark as emergency for priority',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isEmergency,
                        onChanged: (value) => setState(() => _isEmergency = value),
                        activeColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Book Appointment',
                  isLoading: _isLoading,
                  onPressed: _bookAppointment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorSelector() {
    if (_doctorsLoading) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Doctor', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: _selectedDoctorId,
              hint: Text('Choose a doctor', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
              items: _doctors.map<DropdownMenuItem<int>>((doctor) {
                return DropdownMenuItem(
                  value: doctor.id,
                  child: Text('${doctor.fullName} - ${doctor.specialization}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDoctorId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
