import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../clinic/clinic_service.dart';

class RegisterDoctorToClinicScreen extends StatefulWidget {
  const RegisterDoctorToClinicScreen({super.key});

  @override
  State<RegisterDoctorToClinicScreen> createState() => _RegisterDoctorToClinicScreenState();
}

class _RegisterDoctorToClinicScreenState extends State<RegisterDoctorToClinicScreen> {
  final _service = ClinicService();
  final _formKey = GlobalKey<FormState>();
  final _feeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isAvailable = true;
  Map<String, dynamic>? _doctorData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) {
      _doctorData = extra;
      final fee = (extra['consultationFee'] as num?)?.toDouble() ?? 0.0;
      _feeController.text = fee.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'doctorId': _doctorData?['doctorId'] ?? _doctorData?['id'] ?? 0,
        'qrCodeKey': _doctorData?['qrCodeKey'],
        'consultationFee': double.tryParse(_feeController.text) ?? 0.0,
        'isAvailable': _isAvailable,
        'internalNotes': _notesController.text.trim(),
      };

      await _service.registerDoctorToClinic(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor registered successfully')),
        );
        context.go(AppRoutes.clinicDoctors);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _doctorData?['fullName'] ?? '';
    final specialization = _doctorData?['specialization'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Doctor'),
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
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              specialization,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Configuration', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Consultation Fee at this Clinic',
                  hint: 'Enter fee amount',
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.textTertiary),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Fee is required';
                    if (double.tryParse(value) == null) return 'Invalid amount';
                    return null;
                  },
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
                              'Available for Appointments',
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patients can book with this doctor',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        onChanged: (value) => setState(() => _isAvailable = value),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Internal Notes (Optional)',
                  hint: 'Add any internal notes about this doctor',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: 'Register to Clinic',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Cancel',
                  isOutlined: true,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
