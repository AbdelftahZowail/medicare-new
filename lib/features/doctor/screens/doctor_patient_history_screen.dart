import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../doctor/services/doctor_service.dart';

class DoctorPatientHistoryScreen extends StatefulWidget {
  final int patientId;

  const DoctorPatientHistoryScreen({super.key, required this.patientId});

  @override
  State<DoctorPatientHistoryScreen> createState() => _DoctorPatientHistoryScreenState();
}

class _DoctorPatientHistoryScreenState extends State<DoctorPatientHistoryScreen> {
  final _service = DoctorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _service.getPatientHistory(widget.patientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error?.toString() ?? 'Failed to load patient history',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final records = snapshot.data ?? [];

            // Extract patient info from first record if available
            final firstRecord = records.isNotEmpty ? records.first : null;
            final patientName = firstRecord?.patientName ?? '';
            final chronicConditions = firstRecord?.recommendedCare ?? [];
            final currentMedications = firstRecord?.medications ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PatientHeader(
                    name: patientName,
                    age: '65 yrs',
                    gender: 'Female',
                    bloodType: 'Blood Type A+',
                  ),
                  const SizedBox(height: 16),
                  if (chronicConditions.isNotEmpty) ...[
                    Text(
                      'Chronic Conditions',
                      style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chronicConditions.map((condition) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary200),
                          ),
                          child: Text(
                            condition,
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (currentMedications.isNotEmpty) ...[
                    Text(
                      'Current Medications',
                      style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    ...currentMedications.map((med) => _MedicationCard(medication: med)),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Past Medical Records',
                    style: AppTextStyles.heading4.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  if (records.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No medical records found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...records.map((record) => _MedicalRecordCard(record: record)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String bloodType;

  const _PatientHeader({
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodType,
  });

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
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(AssetPaths.patientProfile1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$age  \u2022  $gender  \u2022  $bloodType',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
            child: const Icon(Icons.medication, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  '${medication.dosage}  \u2022  ${medication.duration}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Active',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;

  const _MedicalRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.diagnosis,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.doctorName}  \u2022  ${record.doctorSpecialization}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${record.visitDate.day}/${record.visitDate.month}/${record.visitDate.year}',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
          if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Symptoms: ${record.symptoms}',
              style: AppTextStyles.bodySmall,
            ),
          ],
          if (record.prescription != null && record.prescription!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Prescription: ${record.prescription}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
