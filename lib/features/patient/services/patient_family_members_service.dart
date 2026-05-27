import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/api_service.dart';

class PatientFamilyMembersService {
  final ApiService _api;
  PatientFamilyMembersService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<FamilyMember>> getFamilyMembers() async {
    final response = await _api.getList(
      ApiEndpoints.patientFamilyMembers,
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list
            .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ApiResponse<void>> deleteFamilyMember(int memberId) {
    return _api.delete(
      ApiEndpoints.deleteFamilyMember(memberId),
      fromJson: (_) => null,
    );
  }
}
