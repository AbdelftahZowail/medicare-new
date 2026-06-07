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
    // Parse gender string from backend enum ("Male"/"Female") to int (0/1)
    int? _parseGender(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'male':
            return 0;
          case 'female':
            return 1;
        }
      }
      return null;
    }

    // Parse relation string from backend enum to int
    int _parseRelation(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'parent':
            return 0;
          case 'child':
            return 1;
          case 'spouse':
            return 2;
          case 'sibling':
            return 3;
          case 'other':
            return 4;
        }
      }
      return 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return FamilyMember(
      id: parseInt(json['id']),
      patientId: parseInt(json['patientId']),
      name: json['name']?.toString() ?? '',
      relation: _parseRelation(json['relation']),
      age: json['age'] != null ? parseInt(json['age']) : null,
      gender: _parseGender(json['gender']),
      bloodType: json['bloodType']?.toString(),
      medicalHistory: json['medicalHistory']?.toString(),
      allergies: json['allergies']?.toString(),
      chronicDiseases: json['chronicDiseases']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert int enums back to strings for backend
    String? _genderToString(int? value) {
      if (value == null) return null;
      switch (value) {
        case 0: return 'Male';
        case 1: return 'Female';
        default: return null;
      }
    }

    String _relationToString(int value) {
      switch (value) {
        case 0: return 'Parent';
        case 1: return 'Child';
        case 2: return 'Spouse';
        case 3: return 'Sibling';
        case 4: return 'Other';
        default: return 'Other';
      }
    }

    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'relation': _relationToString(relation),
      'age': age,
      'gender': _genderToString(gender),
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
      'Name': name,
      'Category': category,
      'Dosage': dosage,
      'Duration': duration,
    };
  }
}
