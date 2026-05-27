import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_models.dart';
import '../../../core/services/api_service.dart';

class PatientProfileService {
  final ApiService _api;
  PatientProfileService({ApiService? api}) : _api = api ?? ApiService();

  Future<PatientProfile> getProfile() async {
    final response = await _api.get(
      ApiEndpoints.patientProfile,
      fromJson: (data) => PatientProfile.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<PatientProfile> updateProfile(PatientProfile profile) async {
    final response = await _api.put(
      ApiEndpoints.patientProfile,
      data: profile.toJson(),
      fromJson: (data) => PatientProfile.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
