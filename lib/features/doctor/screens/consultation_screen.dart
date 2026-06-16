import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/appointment_models.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_utils.dart';
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

  final _diagnosisController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<Medication> _medications = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  ConsultationScreenData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _service.getConsultationDetail(widget.appointmentId);

      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log('Error loading consultation data', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage(e);
        });
      }
    }
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

  Future<void> _submitConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final request = CompleteConsultationRequest(
        diagnosis: _diagnosisController.text.trim(),
        medications: _medications.isNotEmpty ? _medications : null,
        instructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      developer.log(
        'Submitting consultation for appointment: ${widget.appointmentId}',
      );

      await _service.completeConsultation(widget.appointmentId, request);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation completed successfully')),
        );
        context.pop();
      }
    } catch (e, stackTrace) {
      developer.log('Error completing consultation', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kEnableDebugTools
                ? 'Failed to complete consultation: ${errorMessage(e)}'
                : 'Failed to complete consultation. Please try again.'),
          ),
        );
      }
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_data == null) {
      return _buildEmptyState();
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient Info Header ──────────────────────────────────────
            _buildPatientHeader(_data!.patient, _data!.appointment),
            const SizedBox(height: 16),

            // ── Chief Complaint (from appointment) ───────────────────────
            if (_data!.appointment.chiefComplaint != null &&
                _data!.appointment.chiefComplaint!.isNotEmpty)
              _SectionCard(
                title: 'Chief Complaint',
                children: [
                  Text(
                    _data!.appointment.chiefComplaint!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            if (_data!.appointment.chiefComplaint != null &&
                _data!.appointment.chiefComplaint!.isNotEmpty)
              const SizedBox(height: 16),

            // ── Medical History ──────────────────────────────────────────
            if (_data!.medicalHistory.isNotEmpty)
              _SectionCard(
                title: 'Medical History',
                children: [
                  ..._data!.medicalHistory.map((record) =>
                      _MedicalHistoryItem(record: record)),
                ],
              ),
            if (_data!.medicalHistory.isNotEmpty)
              const SizedBox(height: 16),

            // ── Previous Visits ──────────────────────────────────────────
            if (_data!.previousVisits.isNotEmpty)
              _SectionCard(
                title: 'Previous Visits',
                children: [
                  ..._data!.previousVisits.map((visit) =>
                      _PreviousVisitItem(visit: visit)),
                ],
              ),
            if (_data!.previousVisits.isNotEmpty)
              const SizedBox(height: 16),

            // ── Previous Diagnoses ───────────────────────────────────────
            if (_data!.previousDiagnoses.isNotEmpty)
              _SectionCard(
                title: 'Previous Diagnoses',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _data!.previousDiagnoses.map((d) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary200),
                        ),
                        child: Text(
                          d,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (_data!.previousDiagnoses.isNotEmpty)
              const SizedBox(height: 16),

            // ── Previous Prescriptions ───────────────────────────────────
            if (_data!.previousPrescriptions.isNotEmpty)
              _SectionCard(
                title: 'Previous Prescriptions',
                children: [
                  ..._data!.previousPrescriptions.map((med) {
                    return _MedicationItem(
                      medication: med,
                      onRemove: null,
                    );
                  }),
                ],
              ),
            if (_data!.previousPrescriptions.isNotEmpty)
              const SizedBox(height: 16),

            // ── Diagnosis Form ───────────────────────────────────────────
            _SectionCard(
              title: 'Diagnosis',
              children: [
                AppTextField(
                  label: 'Diagnosis *',
                  hint: 'Enter primary diagnosis...',
                  controller: _diagnosisController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Diagnosis is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Prescriptions ────────────────────────────────────────────
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

            // ── Instructions ─────────────────────────────────────────────
            _SectionCard(
              title: 'Instructions',
              children: [
                AppTextField(
                  label: 'Instructions',
                  hint: 'Enter post-treatment instructions, follow-up notes...',
                  controller: _instructionsController,
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),

            AppButton(
              text: 'Complete Consultation',
              isLoading: _isSaving,
              onPressed: _submitConsultation,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(ConsultationPatient patient, Appointment appointment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                child: Icon(
                  patient.gender != null &&
                          patient.gender!.toLowerCase() == 'female'
                      ? Icons.female
                      : Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.isFamilyMember ? 'Family Member' : 'Patient',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info chips row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(Icons.calendar_today, '${patient.age} years'),
              if (patient.gender != null)
                _infoChip(
                  patient.gender!.toLowerCase() == 'female'
                      ? Icons.female
                      : Icons.male,
                  patient.gender!,
                ),
              if (patient.bloodType != null)
                _infoChip(Icons.bloodtype, patient.bloodType!),
            ],
          ),

          // Chronic conditions
          if (patient.chronicConditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            Text(
              'Chronic Conditions',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: patient.chronicConditions.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    c,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],

          // Allergies
          if (patient.allergies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Allergies',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: patient.allergies.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    a,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load consultation',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Retry',
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medication_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No consultation data available',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widget: Section Card
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Medical History Item
// ─────────────────────────────────────────────────────────────────────────────

class _MedicalHistoryItem extends StatelessWidget {
  final MedicalRecord record;

  const _MedicalHistoryItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.info,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.doctorName.isNotEmpty
                          ? record.doctorName
                          : 'Visit',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(record.visitDate),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.diagnosis.isNotEmpty ? record.diagnosis : 'No diagnosis',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Previous Visit Item
// ─────────────────────────────────────────────────────────────────────────────

class _PreviousVisitItem extends StatelessWidget {
  final PreviousVisit visit;

  const _PreviousVisitItem({required this.visit});

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
            child: const Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.doctorName,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(visit.visitDate),
                  style: AppTextStyles.bodySmall,
                ),
                if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    visit.diagnosis!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Medication Item (reused from original, onRemove nullable for read-only)
// ─────────────────────────────────────────────────────────────────────────────

class _MedicationItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onRemove;

  const _MedicationItem({
    required this.medication,
    this.onRemove,
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
                if (medication.category.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    medication.category,
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Medication Dialog (kept from original with same Medication model)
// ─────────────────────────────────────────────────────────────────────────────

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
