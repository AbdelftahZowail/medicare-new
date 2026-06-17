import 'shared_models.dart';

class Appointment {
  final int id;
  final int? patientId;
  final String patientName;
  final int? familyMemberId;
  final String? familyMemberName;
  final int doctorId;
  final String doctorName;
  final String specialization;
  final DateTime appointmentDate;
  final String startTime;
  final String? endTime;
  final int status;
  final String statusText;
  final int? queueNumber;
  final int? queueStatus;
  final String refundStatusText;
  final String? notes;
  final String? cancellationReason;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;
  final int? clinicId;
  final String? clinicName;
  final String? clinicAddress;
  final int? currentServingNumber;
  final bool isEmergency;
  final String? chiefComplaint;
  final bool isPaid;
  final int? paymentStatus;
  final String? paymentStatusText;
  final double? consultationFee;
  final String? offlinePatientPhone;
  final int? offlinePatientAge;
  final int? offlinePatientGender;
  final String paymentMethodText;
  final DateTime createdAt;

  /// Resolves the correct display name: family member's name if booking
  /// for a family member, otherwise the primary patient's name.
  String get displayName => familyMemberName ?? patientName;

  Appointment({
    required this.id,
    this.patientId,
    required this.patientName,
    this.familyMemberId,
    this.familyMemberName,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.statusText,
    this.queueNumber,
    this.queueStatus,
    required this.refundStatusText,
    this.notes,
    this.cancellationReason,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.currentServingNumber,
    required this.isEmergency,
    this.chiefComplaint,
    required this.isPaid,
    this.paymentStatus,
    this.paymentStatusText,
    this.consultationFee,
    this.offlinePatientPhone,
    this.offlinePatientAge,
    this.offlinePatientGender,
    required this.paymentMethodText,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      patientId: json['patientId'],
      patientName: json['patientName'] ?? '',
      familyMemberId: json['familyMemberId'],
      familyMemberName: json['familyMemberName'],
      doctorId: json['doctorId'] ?? 0,
      doctorName: json['doctorName'] ?? '',
      specialization: json['specialization'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate'] ?? DateTime.now().toIso8601String()),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'],
      status: _parseStatus(json['status']),
      statusText: json['statusText'] ?? '',
      queueNumber: json['queueNumber'],
      queueStatus: _parseQueueStatus(json['queueStatus']),
      refundStatusText: json['refundStatusText'] ?? '',
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      doctorProfileImageUrl: json['doctorProfileImageUrl'],
      patientProfileImageUrl: json['patientProfileImageUrl'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      currentServingNumber: json['currentServingNumber'],
      isEmergency: json['isEmergency'] ?? false,
      chiefComplaint: json['chiefComplaint'],
      isPaid: json['isPaid'] ?? false,
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      paymentStatusText: json['paymentStatusText'],
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
      offlinePatientPhone: json['offlinePatientPhone'],
      offlinePatientAge: json['offlinePatientAge'],
      offlinePatientGender: json['offlinePatientGender'],
      paymentMethodText: json['paymentMethodText'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static int _parseStatus(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pending': return 0;
        case 'confirmed': return 1;
        case 'inprogress':
        case 'in_progress':
        case 'in progress': return 2;
        case 'completed': return 3;
        case 'cancelled': return 4;
        case 'noshow':
        case 'no_show':
        case 'no show': return 5;
        default: return 0;
      }
    }
    return 0;
  }

  static int? _parsePaymentStatus(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pending': return 0;
        case 'paid': return 1;
        case 'refunded': return 2;
        default: return 0;
      }
    }
    return null;
  }

  static int? _parseQueueStatus(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'waiting': return 0;
        case 'inconsultation':
        case 'in_consultation':
        case 'in consultation': return 1;
        case 'completed': return 2;
        case 'refunded': return 3;
        default: return null;
      }
    }
    return null;
  }
}

class BookAppointmentRequest {
  final int doctorId;
  final DateTime appointmentDate;
  final String startTime;
  final int? familyMemberId;
  final String? notes;

  BookAppointmentRequest({
    required this.doctorId,
    required this.appointmentDate,
    required this.startTime,
    this.familyMemberId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
        'startTime': startTime,
        if (familyMemberId != null) 'familyMemberId': familyMemberId,
        if (notes != null) 'notes': notes,
      };
}

class LiveQueueTracker {
  final int appointmentId;
  final int myQueueNumber;
  final int currentServingNumber;
  final int patientsAheadOfMe;
  final int estimatedWaitTimeMinutes;
  final int? myQueueStatus;
  final String doctorName;

  LiveQueueTracker({
    required this.appointmentId,
    required this.myQueueNumber,
    required this.currentServingNumber,
    required this.patientsAheadOfMe,
    required this.estimatedWaitTimeMinutes,
    this.myQueueStatus,
    required this.doctorName,
  });

  factory LiveQueueTracker.fromJson(Map<String, dynamic> json) {
    return LiveQueueTracker(
      appointmentId: json['appointmentId'] ?? 0,
      myQueueNumber: json['myQueueNumber'] ?? 0,
      currentServingNumber: json['currentServingNumber'] ?? 0,
      patientsAheadOfMe: json['patientsAheadOfMe'] ?? 0,
      estimatedWaitTimeMinutes: json['estimatedWaitTimeMinutes'] ?? 0,
      myQueueStatus: Appointment._parseQueueStatus(json['myQueueStatus']),
      doctorName: json['doctorName'] ?? '',
    );
  }
}

/// Request body for POST /api/doctor/consultation/{appointmentId}/complete
class CompleteConsultationRequest {
  final String diagnosis;
  final List<Medication>? medications;
  final String? instructions;

  CompleteConsultationRequest({
    required this.diagnosis,
    this.medications,
    this.instructions,
  });

  Map<String, dynamic> toJson() => {
        'diagnosis': diagnosis,
        if (medications != null) 'medications': medications!.map((m) => m.toJson()).toList(),
        if (instructions != null) 'instructions': instructions,
      };
}

/// Patient info within ConsultationScreenDto
class ConsultationPatient {
  final int? patientId;
  final int? familyMemberId;
  final String fullName;
  final String? profileImageUrl;
  final int age;
  final String? gender;
  final String? bloodType;
  final List<String> chronicConditions;
  final List<String> allergies;
  final bool isFamilyMember;

  ConsultationPatient({
    this.patientId,
    this.familyMemberId,
    required this.fullName,
    this.profileImageUrl,
    required this.age,
    this.gender,
    this.bloodType,
    this.chronicConditions = const [],
    this.allergies = const [],
    this.isFamilyMember = false,
  });

  factory ConsultationPatient.fromJson(Map<String, dynamic> json) {
    return ConsultationPatient(
      patientId: json['patientId'],
      familyMemberId: json['familyMemberId'],
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      age: json['age'] ?? 0,
      gender: json['gender'],
      bloodType: json['bloodType'],
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      isFamilyMember: json['isFamilyMember'] ?? false,
    );
  }
}

/// Previous visit entry within ConsultationScreenDto
class PreviousVisit {
  final int appointmentId;
  final DateTime visitDate;
  final String doctorName;
  final String? diagnosis;
  final String? chiefComplaint;

  PreviousVisit({
    required this.appointmentId,
    required this.visitDate,
    required this.doctorName,
    this.diagnosis,
    this.chiefComplaint,
  });

  factory PreviousVisit.fromJson(Map<String, dynamic> json) {
    return PreviousVisit(
      appointmentId: json['appointmentId'] ?? 0,
      visitDate: DateTime.parse(json['visitDate'] ?? DateTime.now().toIso8601String()),
      doctorName: json['doctorName'] ?? '',
      diagnosis: json['diagnosis'],
      chiefComplaint: json['chiefComplaint'],
    );
  }
}

/// Full consultation screen data from GET /api/doctor/consultation/{appointmentId}
class ConsultationScreenData {
  final Appointment appointment;
  final ConsultationPatient patient;
  final List<MedicalRecord> medicalHistory;
  final List<PreviousVisit> previousVisits;
  final List<String> previousDiagnoses;
  final List<Medication> previousPrescriptions;

  ConsultationScreenData({
    required this.appointment,
    required this.patient,
    this.medicalHistory = const [],
    this.previousVisits = const [],
    this.previousDiagnoses = const [],
    this.previousPrescriptions = const [],
  });

  factory ConsultationScreenData.fromJson(Map<String, dynamic> json) {
    return ConsultationScreenData(
      appointment: Appointment.fromJson(json['appointment'] ?? {}),
      patient: ConsultationPatient.fromJson(json['patient'] ?? {}),
      medicalHistory: json['medicalHistory'] != null
          ? List<MedicalRecord>.from(
              json['medicalHistory'].map((x) => MedicalRecord.fromJson(x)),
            )
          : [],
      previousVisits: json['previousVisits'] != null
          ? List<PreviousVisit>.from(
              json['previousVisits'].map((x) => PreviousVisit.fromJson(x)),
            )
          : [],
      previousDiagnoses: List<String>.from(json['previousDiagnoses'] ?? []),
      previousPrescriptions: json['previousPrescriptions'] != null
          ? List<Medication>.from(
              json['previousPrescriptions'].map((x) => Medication.fromJson(x)),
            )
          : [],
    );
  }
}

/// Patient history wrapper returned by GET /api/doctor/patients/{patientId}/history
class PatientHistoryData {
  final int patientId;
  final String fullName;
  final String? profileImageUrl;
  final int age;
  final String? gender;
  final String? bloodType;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final List<MedicalRecord> pastRecords;

  PatientHistoryData({
    required this.patientId,
    required this.fullName,
    this.profileImageUrl,
    required this.age,
    this.gender,
    this.bloodType,
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.pastRecords = const [],
  });

  factory PatientHistoryData.fromJson(Map<String, dynamic> json) {
    return PatientHistoryData(
      patientId: json['patientId'] ?? 0,
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      age: json['age'] ?? 0,
      gender: json['gender'],
      bloodType: json['bloodType'],
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      currentMedications: List<String>.from(json['currentMedications'] ?? []),
      pastRecords: json['pastRecords'] != null
          ? List<MedicalRecord>.from(
              json['pastRecords'].map((x) => MedicalRecord.fromJson(x)),
            )
          : [],
    );
  }
}
