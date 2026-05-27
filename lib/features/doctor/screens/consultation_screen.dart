import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../doctor/services/doctor_service.dart';

class ConsultationScreen extends StatefulWidget {
  final int appointmentId;

  const ConsultationScreen({super.key, required this.appointmentId});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _service = DoctorService();
  final _formKey = GlobalKey<FormState>();

  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _planController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Medication> _medications = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        onAdd: (med) {
          setState(() => _medications.add(med));
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() => _medications.removeAt(index));
  }

  Future<void> _saveConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      'subjective': _subjectiveController.text,
      'objective': _objectiveController.text,
      'assessment': _assessmentController.text,
      'plan': _planController.text,
      'bloodPressure': _bloodPressureController.text,
      'heartRate': int.tryParse(_heartRateController.text),
      'weight': double.tryParse(_weightController.text),
      'diagnosis': _diagnosisController.text,
      'notes': _notesController.text,
      'medications': _medications.map((m) => m.toJson()).toList(),
    };

    final success = await _service.saveConsultation(widget.appointmentId, data);

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation saved successfully')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save consultation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOAP Section
                _SectionCard(
                  title: 'SOAP Summary',
                  children: [
                    AppTextField(
                      label: 'Subjective',
                      hint: 'Patient\'s chief complaint...',
                      controller: _subjectiveController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Objective',
                      hint: 'Physical findings, test results...',
                      controller: _objectiveController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Assessment',
                      hint: 'Diagnosis and clinical impression...',
                      controller: _assessmentController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Plan',
                      hint: 'Treatment plan and follow-up...',
                      controller: _planController,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Vitals Section
                _SectionCard(
                  title: 'Vitals',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Blood Pressure',
                            hint: '120/80',
                            controller: _bloodPressureController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Heart Rate',
                            hint: '72 bpm',
                            controller: _heartRateController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Weight',
                      hint: '70 kg',
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Diagnosis
                _SectionCard(
                  title: 'Diagnosis',
                  children: [
                    AppTextField(
                      label: 'Primary Diagnosis',
                      hint: 'Enter diagnosis...',
                      controller: _diagnosisController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Prescriptions
                _SectionCard(
                  title: 'Prescriptions',
                  children: [
                    if (_medications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No medications added yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._medications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final med = entry.value;
                        return _MedicationItem(
                          medication: med,
                          onRemove: () => _removeMedication(index),
                        );
                      }),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Add Prescription',
                      isOutlined: true,
                      onPressed: _addMedication,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Notes
                _SectionCard(
                  title: 'Additional Notes',
                  children: [
                    AppTextField(
                      label: 'Notes',
                      hint: 'Enter any additional notes...',
                      controller: _notesController,
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Save Consultation',
                  isLoading: _isSaving,
                  onPressed: _saveConsultation,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _MedicationItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onRemove;

  const _MedicationItem({
    required this.medication,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${medication.dosage}  \u2022  ${medication.duration}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final Function(Medication) onAdd;

  const _AddMedicationDialog({required this.onAdd});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) return;

    widget.onAdd(Medication(
      name: _nameController.text,
      category: _categoryController.text,
      dosage: _dosageController.text,
      duration: _durationController.text,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Medication', style: AppTextStyles.heading3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Medication Name',
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Category',
              controller: _categoryController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Dosage',
              controller: _dosageController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Duration',
              controller: _durationController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
