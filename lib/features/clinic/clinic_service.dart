import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/api_service.dart';

class ClinicService {
  final _api = ApiService();

  Future<Map<String, dynamic>> getClinicDashboard({required int doctorId}) async {
    final response = await _api.get(
      ApiEndpoints.appointmentClinicDashboard,
      queryParameters: {'doctorId': doctorId},
      fromJson: (data) => data as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<dynamic>> getClinicQueue({required int doctorId}) async {
    final response = await _api.getList(
      ApiEndpoints.appointmentClinicQueue,
      queryParameters: {'doctorId': doctorId},
      fromJson: (data) => data as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<DoctorListItem>> getClinicDoctors() async {
    final response = await _api.getList(
      ApiEndpoints.clinicDoctors,
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => DoctorListItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<Map<String, dynamic>> scanDoctorQr(String qrCodeKey) async {
    final response = await _api.get(
      ApiEndpoints.clinicDoctorScan(qrCodeKey),
      fromJson: (data) => data as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> registerDoctorToClinic(Map<String, dynamic> data) async {
    final response = await _api.post(
      ApiEndpoints.clinicDoctorRegister,
      data: data,
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<ClinicProfile> getClinicProfile() async {
    final response = await _api.get(
      ApiEndpoints.clinicProfile,
      fromJson: (data) => ClinicProfile.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ClinicProfile> updateClinicProfile(Map<String, dynamic> data) async {
    final response = await _api.put(
      ApiEndpoints.clinicProfile,
      data: data,
      fromJson: (data) => ClinicProfile.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<Map<String, dynamic>> getClinicPayments({required int doctorId, required String timeframe}) async {
    final response = await _api.get(
      ApiEndpoints.appointmentClinicPayments,
      queryParameters: {'doctorId': doctorId, 'timeframe': timeframe},
      fromJson: (data) => data as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> bookWalkInAppointment(Map<String, dynamic> data) async {
    final response = await _api.post(
      ApiEndpoints.appointmentClinicBooking,
      data: data,
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final response = await _api.getList(
      ApiEndpoints.patientSearch,
      queryParameters: {'q': query},
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _api.getList(
      ApiEndpoints.notifications,
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> markNotificationRead(int id) async {
    final response = await _api.post(
      ApiEndpoints.markNotificationRead(id),
      data: {},
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<void> startCheckup(int appointmentId) async {
    final response = await _api.post(
      ApiEndpoints.appointmentStartCheckup(appointmentId),
      data: {},
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<void> removeDoctorFromClinic(int doctorId) async {
    final response = await _api.delete(
      ApiEndpoints.clinicDoctorDelete(doctorId),
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<DoctorProfile> getClinicDoctorDetail(int doctorId) async {
    final response = await _api.get(
      ApiEndpoints.clinicDoctorDetail(doctorId),
      fromJson: (data) => DoctorProfile.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<DoctorSchedule>> getDoctorSchedules(int doctorId) async {
    final response = await _api.get(
      ApiEndpoints.doctorSchedules(doctorId),
      fromJson: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.map((e) => DoctorSchedule.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<void> updateClinicDoctor(int doctorId, Map<String, dynamic> data) async {
    final response = await _api.put(
      ApiEndpoints.clinicDoctorUpdate(doctorId),
      data: data,
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }

  Future<void> updateDoctorSchedule(int doctorId, List<Map<String, dynamic>> schedules) async {
    for (final schedule in schedules) {
      if (kDebugMode) {
        print('--- Sending schedule ---');
        print('Schedule data: $schedule');
      }
      final response = await _api.post(
        ApiEndpoints.clinicAddSchedule(doctorId),
        data: {
          ...schedule,
          'doctorId': doctorId,
        },
        fromJson: (data) => data,
      );
      if (kDebugMode) {
        print('Schedule response: isSuccess=${response.isSuccess} message="${response.message}" errors=${response.errors}');
      }
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final response = await _api.delete(
      ApiEndpoints.clinicDeleteSchedule(scheduleId),
      fromJson: (data) => data,
    );
    if (!response.isSuccess) {
      throw Exception(response.message);
    }
  }
}
