class DoctorProfile {
  final int id;
  final int userId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? profileImageUrl;
  final String specialization;
  final String? licenseNumber;
  final String? licenseImageUrl;
  final int? yearsOfExperience;
  final String? bio;
  final double consultationFee;
  final double averageRating;
  final int totalReviews;
  final bool isAvailable;
  final int? clinicId;
  final String? clinicName;
  final String? degree;
  final String? university;
  final String? subSpecialty;
  final int? graduationYear;
  final String? boardCertification;
  final List<String> languages;
  final List<String> associatedClinics;
  final int totalPatients;
  final String? qrCodeKey;

  DoctorProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profileImageUrl,
    required this.specialization,
    this.licenseNumber,
    this.licenseImageUrl,
    this.yearsOfExperience,
    this.bio,
    required this.consultationFee,
    required this.averageRating,
    required this.totalReviews,
    required this.isAvailable,
    this.clinicId,
    this.clinicName,
    this.degree,
    this.university,
    this.subSpecialty,
    this.graduationYear,
    this.boardCertification,
    required this.languages,
    required this.associatedClinics,
    required this.totalPatients,
    this.qrCodeKey,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DoctorProfile(
      id: parseInt(json['id']),
      userId: parseInt(json['userId']),
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      specialization: json['specialization']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString(),
      licenseImageUrl: json['licenseImageUrl']?.toString(),
      yearsOfExperience: json['yearsOfExperience'] != null ? parseInt(json['yearsOfExperience']) : null,
      bio: json['bio']?.toString(),
      consultationFee: parseDouble(json['consultationFee']),
      averageRating: parseDouble(json['averageRating']),
      totalReviews: parseInt(json['totalReviews']),
      isAvailable: json['isAvailable'] ?? false,
      clinicId: json['clinicId'] != null ? parseInt(json['clinicId']) : null,
      clinicName: json['clinicName']?.toString(),
      degree: json['degree']?.toString(),
      university: json['university']?.toString(),
      subSpecialty: json['subSpecialty']?.toString(),
      graduationYear: json['graduationYear'] != null ? parseInt(json['graduationYear']) : null,
      boardCertification: json['boardCertification']?.toString(),
      languages: json['languages'] != null
          ? List<String>.from(json['languages'].map((x) => x.toString()))
          : [],
      associatedClinics: json['associatedClinics'] != null
          ? List<String>.from(json['associatedClinics'].map((x) => x.toString()))
          : [],
      totalPatients: parseInt(json['totalPatients']),
      qrCodeKey: json['qrCodeKey']?.toString(),
    );
  }
}

class DoctorListItem {
  final int id;
  final String fullName;
  final String specialization;
  final String? profileImageUrl;
  final double consultationFee;
  final double averageRating;
  final int totalReviews;
  final bool isAvailable;
  final String? clinicName;
  final String? clinicArea;
  final bool isFavorited;
  final double? latitude;
  final double? longitude;

  DoctorListItem({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.profileImageUrl,
    required this.consultationFee,
    required this.averageRating,
    required this.totalReviews,
    required this.isAvailable,
    this.clinicName,
    this.clinicArea,
    required this.isFavorited,
    this.latitude,
    this.longitude,
  });

  factory DoctorListItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DoctorListItem(
      id: parseInt(json['id']),
      fullName: json['fullName']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      consultationFee: parseDouble(json['consultationFee']),
      averageRating: parseDouble(json['averageRating']),
      totalReviews: parseInt(json['totalReviews']),
      isAvailable: json['isAvailable'] ?? false,
      clinicName: json['clinicName']?.toString(),
      clinicArea: json['clinicArea']?.toString(),
      isFavorited: json['isFavorited'] ?? false,
      latitude: json['latitude'] != null ? parseDouble(json['latitude']) : null,
      longitude: json['longitude'] != null ? parseDouble(json['longitude']) : null,
    );
  }
}

class DoctorSchedule {
  final int id;
  final int doctorId;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int maxPatients;
  final bool isActive;

  DoctorSchedule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.maxPatients,
    required this.isActive,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    final dayOfWeekValue = _parseDayOfWeek(json['dayOfWeek']);
    
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return DoctorSchedule(
      id: parseInt(json['id']),
      doctorId: parseInt(json['doctorId']),
      dayOfWeek: dayOfWeekValue,
      dayName: json['dayName']?.toString() ?? _dayOfWeekToString(dayOfWeekValue),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      slotDurationMinutes: parseInt(json['slotDurationMinutes']),
      maxPatients: parseInt(json['maxPatients']),
      isActive: json['isActive'] ?? true,
    );
  }

  static int _parseDayOfWeek(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'sunday': return 0;
        case 'monday': return 1;
        case 'tuesday': return 2;
        case 'wednesday': return 3;
        case 'thursday': return 4;
        case 'friday': return 5;
        case 'saturday': return 6;
        default: return 0;
      }
    }
    return 0;
  }

  static String _dayOfWeekToString(int day) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return day >= 0 && day < days.length ? days[day] : 'Unknown';
  }
}

class AvailableSlot {
  final String time;
  final bool isAvailable;

  AvailableSlot({required this.time, required this.isAvailable});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      time: json['time'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}
