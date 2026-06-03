import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/shared_models.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/patient_medical_history_service.dart';
import '../services/patient_profile_service.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  bool _loading = true;
  List<MedicalRecord> _records = [];
  List<String> _chronicConditions = [];

  final _medicalService = PatientMedicalHistoryService();
  final _profileService = PatientProfileService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final patientId = await AuthService().getProfileId();
      if (patientId == null) {
        throw Exception('Patient ID not found');
      }

      final records = await _medicalService.getMedicalRecords(patientId);
      final profile = await _profileService.getProfile();

      if (!mounted) return;

      final chronicDiseases = profile.chronicDiseases;
      setState(() {
        _records = records;
        _chronicConditions = chronicDiseases != null && chronicDiseases.isNotEmpty
            ? chronicDiseases.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
            : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _records = [];
        _chronicConditions = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load medical history: ${e.toString()}')),
      );
    }
  }

  List<Medication> get _allMedications {
    final meds = <Medication>[];
    for (final record in _records) {
      if (record.medications != null) {
        meds.addAll(record.medications!);
      }
    }
    return meds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medical History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chronic Conditions
                      Text('Chronic Conditions', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      if (_chronicConditions.isEmpty)
                        Text(
                          'No chronic conditions recorded',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _chronicConditions.map((condition) {
                            return Chip(
                              label: Text(condition),
                              backgroundColor: AppColors.errorBg,
                              labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: AppColors.errorBg),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 24),

                      // Medications
                      Text('Current Medications', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      if (_allMedications.isEmpty)
                        Text(
                          'No medications recorded',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        )
                      else
                        ..._allMedications.map((med) => _MedicationCard(medication: med)),
                      const SizedBox(height: 24),

                      // Lab Tests / Visit History
                      Text('Visit History', style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      if (_records.isEmpty)
                        Text(
                          'No visit history recorded',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        )
                      else
                        ..._records.map((record) => _VisitCard(record: record)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  const _MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.dosage} - ${medication.category}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Duration: ${medication.duration}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final MedicalRecord record;
  const _VisitCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary100,
                backgroundImage: record.doctorProfileImageUrl != null
                    ? NetworkImage(record.doctorProfileImageUrl!)
                    : null,
                child: record.doctorProfileImageUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.doctorName,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.doctorSpecialization,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(record.visitDate),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const Divider(height: 24),
          _VisitDetailRow(label: 'Diagnosis', value: record.diagnosis),
          if (record.prescription != null) ...[
            const SizedBox(height: 8),
            _VisitDetailRow(label: 'Prescription', value: record.prescription!),
          ],
          if (record.bloodPressure != null) ...[
            const SizedBox(height: 8),
            _VisitDetailRow(label: 'Blood Pressure', value: record.bloodPressure!),
          ],
          if (record.heartRate != null) ...[
            const SizedBox(height: 8),
            _VisitDetailRow(label: 'Heart Rate', value: '${record.heartRate} bpm'),
          ],
        ],
      ),
    );
  }
}

class _VisitDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _VisitDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
