class NotificationItem {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? type;
  final int? relatedId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.relatedId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      type: json['type'],
      relatedId: json['relatedId'],
    );
  }
}

class FamilyMember {
  final int id;
  final int patientId;
  final String name;
  final int relation;
  final int? age;
  final int? gender;
  final String? bloodType;
  final String? medicalHistory;
  final String? allergies;
  final String? chronicDiseases;

  FamilyMember({
    required this.id,
    required this.patientId,
    required this.name,
    required this.relation,
    this.age,
    this.gender,
    this.bloodType,
    this.medicalHistory,
    this.allergies,
    this.chronicDiseases,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      name: json['name'] ?? '',
      relation: json['relation'] ?? 0,
      age: json['age'],
      gender: json['gender'],
      bloodType: json['bloodType'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      chronicDiseases: json['chronicDiseases'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'relation': relation,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
    };
  }
}

class Review {
  final int id;
  final int doctorId;
  final int patientId;
  final String patientName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      doctorId: json['doctorId'] ?? 0,
      patientId: json['patientId'] ?? 0,
      patientName: json['patientName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class MedicalRecord {
  final int id;
  final int patientId;
  final String patientName;
  final int doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String? doctorProfileImageUrl;
  final int? appointmentId;
  final String diagnosis;
  final String? prescription;
  final String? treatmentPlan;
  final String? notes;
  final String? symptoms;
  final String? subjective;
  final String? objective;
  final String? assessment;
  final String? plan;
  final String? bloodPressure;
  final int? heartRate;
  final double? weight;
  final List<Medication>? medications;
  final String? observations;
  final List<String>? recommendedCare;
  final DateTime visitDate;
  final DateTime createdAt;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    this.doctorProfileImageUrl,
    this.appointmentId,
    required this.diagnosis,
    this.prescription,
    this.treatmentPlan,
    this.notes,
    this.symptoms,
    this.subjective,
    this.objective,
    this.assessment,
    this.plan,
    this.bloodPressure,
    this.heartRate,
    this.weight,
    this.medications,
    this.observations,
    this.recommendedCare,
    required this.visitDate,
    required this.createdAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? 0,
      patientId: json['patientId'] ?? 0,
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? 0,
      doctorName: json['doctorName'] ?? '',
      doctorSpecialization: json['doctorSpecialization'] ?? '',
      doctorProfileImageUrl: json['doctorProfileImageUrl'],
      appointmentId: json['appointmentId'],
      diagnosis: json['diagnosis'] ?? '',
      prescription: json['prescription'],
      treatmentPlan: json['treatmentPlan'],
      notes: json['notes'],
      symptoms: json['symptoms'],
      subjective: json['subjective'],
      objective: json['objective'],
      assessment: json['assessment'],
      plan: json['plan'],
      bloodPressure: json['bloodPressure'],
      heartRate: json['heartRate'],
      weight: json['weight']?.toDouble(),
      medications: json['medications'] != null
          ? List<Medication>.from(
              json['medications'].map((x) => Medication.fromJson(x)),
            )
          : null,
      observations: json['observations'],
      recommendedCare: json['recommendedCare'] != null
          ? List<String>.from(json['recommendedCare'])
          : null,
      visitDate: DateTime.parse(json['visitDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Medication {
  final String name;
  final String category;
  final String dosage;
  final String duration;

  Medication({
    required this.name,
    required this.category,
    required this.dosage,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      dosage: json['dosage'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'dosage': dosage,
      'duration': duration,
    };
  }
}
