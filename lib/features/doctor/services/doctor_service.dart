import '../../../core/constants/app_constants.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/models/community_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/api_service.dart';

class DoctorService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get(
      ApiEndpoints.doctorDashboard,
      fromJson: (data) => data as Map<String, dynamic>,
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load dashboard');
    }
    return response.data!;
  }

  Future<List<Appointment>> getAppointments({DateTime? date}) async {
    final query = <String, dynamic>{};
    if (date != null) {
      query['date'] = date.toIso8601String().split('T')[0];
    }
    final response = await _api.getList(
      ApiEndpoints.doctorAppointments,
      queryParameters: query.isNotEmpty ? query : null,
      fromJson: (data) =>
          (data as List).map((e) => Appointment.fromJson(e)).toList(),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load appointments');
    }
    return response.data!;
  }

  Future<List<Appointment>> getLiveQueue() async {
    final response = await _api.getList(
      ApiEndpoints.doctorLiveQueue,
      fromJson: (data) =>
          (data as List).map((e) => Appointment.fromJson(e)).toList(),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load queue');
    }
    return response.data!;
  }

  Future<bool> callNextPatient() async {
    final response = await _api.post(
      ApiEndpoints.appointmentCallNext,
      fromJson: (data) => data,
    );
    return response.isSuccess;
  }

  Future<DoctorProfile> getProfile() async {
    final response = await _api.get(
      ApiEndpoints.doctorProfile,
      fromJson: (data) => DoctorProfile.fromJson(data),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load profile');
    }
    return response.data!;
  }

  Future<DoctorProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put(
      ApiEndpoints.doctorProfile,
      data: data,
      fromJson: (data) => DoctorProfile.fromJson(data),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to update profile');
    }
    return response.data!;
  }

  Future<String> getQrCode() async {
    final response = await _api.get(
      ApiEndpoints.doctorQrCode,
      fromJson: (data) => data as String,
    );
    if (!response.isSuccess || response.data == null || (response.data as String).isEmpty) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load QR code');
    }
    return response.data as String;
  }

  Future<List<MedicalRecord>> getPatientHistory(int patientId) async {
    final response = await _api.getList(
      ApiEndpoints.doctorPatientHistory(patientId),
      fromJson: (data) =>
          (data as List).map((e) => MedicalRecord.fromJson(e)).toList(),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load patient history');
    }
    return response.data!;
  }

  Future<bool> saveConsultation(
    int appointmentId,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.post(
      ApiEndpoints.doctorSession(appointmentId),
      data: data,
      fromJson: (data) => data,
    );
    return response.isSuccess;
  }

  Future<List<CommunityPost>> getCommunityPosts() async {
    final response = await _api.getList(
      ApiEndpoints.communityPosts,
      fromJson: (data) =>
          (data as List).map((e) => CommunityPost.fromJson(e)).toList(),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load community posts');
    }
    return response.data!;
  }

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _api.getList(
      ApiEndpoints.notifications,
      fromJson: (data) =>
          (data as List).map((e) => NotificationItem.fromJson(e)).toList(),
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message.isNotEmpty ? response.message : 'Failed to load notifications');
    }
    return response.data!;
  }
}
