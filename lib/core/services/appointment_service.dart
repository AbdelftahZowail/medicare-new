import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/appointment_models.dart';
import '../../core/services/api_service.dart';

class AppointmentService {
  AppointmentService({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;

  Future<Appointment> bookAppointment(BookAppointmentRequest request) async {
    try {
      final res = await _api.post<Appointment>(
        ApiEndpoints.appointments,
        data: request.toJson(),
        fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('bookAppointment failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: AppointmentService.bookAppointment returning mock data');
    return _mockAppointment(request.doctorId);
  }

  Future<List<Appointment>> getPatientAppointments({String? filter}) async {
    try {
      final res = await _api.getList<Appointment>(
        ApiEndpoints.patientAppointments,
        queryParameters: filter != null ? {'filter': filter} : null,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(Appointment.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('getPatientAppointments failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: AppointmentService.getPatientAppointments returning mock data');
    return _mockAppointments;
  }

  Future<Appointment> getAppointmentDetail(int id) async {
    try {
      final res = await _api.get<Appointment>(
        ApiEndpoints.appointmentDetail(id),
        fromJson: (data) => Appointment.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('getAppointmentDetail failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: AppointmentService.getAppointmentDetail returning mock data');
    return _mockAppointments.firstWhere((a) => a.id == id, orElse: () => _mockAppointments.first);
  }

  Future<void> cancelAppointment(int id, {String? reason}) async {
    try {
      await _api.put<dynamic>(
        ApiEndpoints.appointmentCancel(id),
        data: {'cancellationReason': reason},
        fromJson: (_) => null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('cancelAppointment failed: $e');
    }
  }

  Future<LiveQueueTracker> getQueueTracker(int appointmentId) async {
    try {
      final res = await _api.get<LiveQueueTracker>(
        ApiEndpoints.appointmentQueueTracker(appointmentId),
        fromJson: (data) => LiveQueueTracker.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('getQueueTracker failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return LiveQueueTracker(
      appointmentId: appointmentId,
      myQueueNumber: 5,
      currentServingNumber: 2,
      patientsAheadOfMe: 3,
      estimatedWaitTimeMinutes: 45,
      myQueueStatus: 0,
      doctorName: 'Dr. Ahmed',
    );
  }
}

Appointment _mockAppointment(int doctorId) => Appointment(
  id: 1,
  patientId: 1,
  patientName: 'Ahmed',
  doctorId: doctorId,
  doctorName: 'Dr. Ahmed',
  specialization: 'Dentist',
  appointmentDate: DateTime.now().add(const Duration(days: 1)),
  startTime: '10:30 AM',
  status: 1,
  statusText: 'Confirmed',
  queueNumber: 5,
  refundStatusText: '',
  clinicName: 'Medicare Clinic',
  clinicAddress: 'Maddi, Cairo',
  isEmergency: false,
  isPaid: false,
  paymentMethodText: 'Cash',
  createdAt: DateTime.now(),
);

final _mockAppointments = <Appointment>[
  Appointment(
    id: 1,
    patientId: 1,
    patientName: 'Ahmed',
    doctorId: 1,
    doctorName: 'Dr. Ahmed',
    specialization: 'Dentist',
    appointmentDate: DateTime.now().add(const Duration(days: 1)),
    startTime: '10:30 AM',
    status: 1,
    statusText: 'Confirmed',
    queueNumber: 5,
    refundStatusText: '',
    clinicName: 'Medicare Clinic',
    clinicAddress: 'Maddi, Cairo',
    isEmergency: false,
    isPaid: false,
    paymentMethodText: 'Cash',
    createdAt: DateTime.now(),
  ),
  Appointment(
    id: 2,
    patientId: 1,
    patientName: 'Ahmed',
    doctorId: 2,
    doctorName: 'Dr. Mohamed',
    specialization: 'Cardiologist',
    appointmentDate: DateTime.now().add(const Duration(days: 3)),
    startTime: '02:00 PM',
    status: 0,
    statusText: 'Pending',
    refundStatusText: '',
    clinicName: 'Heart Care Center',
    clinicAddress: 'Dokki, Cairo',
    isEmergency: false,
    isPaid: false,
    paymentMethodText: 'Cash',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Appointment(
    id: 3,
    patientId: 1,
    patientName: 'Ahmed',
    doctorId: 3,
    doctorName: 'Dr. Sara',
    specialization: 'Neurology',
    appointmentDate: DateTime.now().subtract(const Duration(days: 5)),
    startTime: '09:00 AM',
    status: 3,
    statusText: 'Completed',
    refundStatusText: '',
    clinicName: 'Neuro Center',
    clinicAddress: 'Nasr City, Cairo',
    isEmergency: false,
    isPaid: true,
    paymentMethodText: 'Online',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
