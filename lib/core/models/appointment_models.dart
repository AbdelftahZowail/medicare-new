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
  final int? clinicId;
  final String? clinicName;
  final String? clinicAddress;
  final int? currentServingNumber;
  final bool isEmergency;
  final String? chiefComplaint;
  final bool isPaid;
  final String paymentMethodText;
  final DateTime createdAt;

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
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.currentServingNumber,
    required this.isEmergency,
    this.chiefComplaint,
    required this.isPaid,
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
      status: json['status'] ?? 0,
      statusText: json['statusText'] ?? '',
      queueNumber: json['queueNumber'],
      queueStatus: json['queueStatus'],
      refundStatusText: json['refundStatusText'] ?? '',
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      doctorProfileImageUrl: json['doctorProfileImageUrl'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
      currentServingNumber: json['currentServingNumber'],
      isEmergency: json['isEmergency'] ?? false,
      chiefComplaint: json['chiefComplaint'],
      isPaid: json['isPaid'] ?? false,
      paymentMethodText: json['paymentMethodText'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class BookAppointmentRequest {
  final int doctorId;
  final DateTime appointmentDate;
  final String startTime;
  final int? familyMemberId;
  final String? notes;
  final bool isEmergency;
  final String? chiefComplaint;

  BookAppointmentRequest({
    required this.doctorId,
    required this.appointmentDate,
    required this.startTime,
    this.familyMemberId,
    this.notes,
    this.isEmergency = false,
    this.chiefComplaint,
  });

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
        'startTime': startTime,
        if (familyMemberId != null) 'familyMemberId': familyMemberId,
        if (notes != null) 'notes': notes,
        'isEmergency': isEmergency,
        if (chiefComplaint != null) 'chiefComplaint': chiefComplaint,
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
      myQueueStatus: json['myQueueStatus'],
      doctorName: json['doctorName'] ?? '',
    );
  }
}
