import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/appointment_models.dart';
import '../../../core/services/api_service.dart';

class PatientAppointmentsService {
  final ApiService _api;

  PatientAppointmentsService({ApiService? api}) : _api = api ?? ApiService();

  Future<Appointment> bookAppointment(
    BookAppointmentRequest request,
  ) async {
    final response = await _api.post(
      ApiEndpoints.appointments,
      data: request.toJson(),
      fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<Appointment>> getMyAppointments({
    String? filter,
  }) async {
    final response = await _api.getList(
      ApiEndpoints.patientAppointments,
      queryParameters: filter == null ? null : {'filter': filter},
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<Appointment> getAppointmentDetail(int id) async {
    final response = await _api.get(
      ApiEndpoints.appointmentDetail(id),
      fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ApiResponse<Appointment>> cancelAppointment(
    int id, {
    String? reason,
  }) async {
    final response = await _api.put(
      ApiEndpoints.appointmentCancel(id),
      data: reason == null ? {} : {'reason': reason},
      fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response;
    }
    throw Exception(response.message);
  }

  Future<ApiResponse<Appointment>> rescheduleAppointment(
    int id, {
    required DateTime appointmentDate,
    required String startTime,
  }) async {
    final response = await _api.put(
      ApiEndpoints.appointmentReschedule(id),
      data: {
        'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
        'startTime': startTime,
      },
      fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response;
    }
    throw Exception(response.message);
  }

  Future<LiveQueueTracker> getQueueTracker(int appointmentId) async {
    final response = await _api.get(
      ApiEndpoints.appointmentQueueTracker(appointmentId),
      fromJson: (data) => LiveQueueTracker.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
