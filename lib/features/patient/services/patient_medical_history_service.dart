import '../../../core/constants/app_constants.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/api_service.dart';

class PatientMedicalHistoryService {
  final ApiService _api;
  PatientMedicalHistoryService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<MedicalRecord>> getMedicalRecords(int patientId) async {
    final response = await _api.getList(
      ApiEndpoints.patientMedicalRecords(patientId),
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list
            .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
