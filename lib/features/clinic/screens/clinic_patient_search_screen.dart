import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_utils.dart';
import '../../clinic/clinic_service.dart';

class ClinicPatientSearchScreen extends StatefulWidget {
  const ClinicPatientSearchScreen({super.key});

  @override
  State<ClinicPatientSearchScreen> createState() => _ClinicPatientSearchScreenState();
}

class _ClinicPatientSearchScreenState extends State<ClinicPatientSearchScreen> {
  final _service = ClinicService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final patients = await _service.searchPatients(query);
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textTertiary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _search(),
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textTertiary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _patients = [];
                            _hasSearched = false;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: _search,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : !_hasSearched
                          ? _buildInitialState()
                          : _patients.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  itemCount: _patients.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final patient = _patients[index];
                                    return _PatientCard(patient: patient);
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Search failed',
              style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Search for patients',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a name or phone number to find patients',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final name = patient['name'] ?? '';
    final phone = patient['phoneNumber'] ?? '';
    final id = patient['id']?.toString() ?? '--';
    final age = patient['age']?.toString();
    final gender = patient['gender'] == 0 ? 'Male' : patient['gender'] == 1 ? 'Female' : null;

    return InkWell(
      onTap: () {
        final patientId = patient['id'] as int?;
        if (patientId != null) {
          context.push('${AppRoutes.doctorPatientHistory}/$patientId');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient history for $name')),
          );
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(AssetPaths.patientProfile1),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: AppTextStyles.bodySmall,
                  ),
                  if (age != null || gender != null)
                    Text(
                      '${age != null ? '$age years' : ''}${age != null && gender != null ? ' · ' : ''}${gender ?? ''}',
                      style: AppTextStyles.labelSmall,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: $id',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
