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
    this.qrCodeKey,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      specialization: json['specialization'] ?? '',
      licenseNumber: json['licenseNumber'],
      licenseImageUrl: json['licenseImageUrl'],
      yearsOfExperience: json['yearsOfExperience'],
      bio: json['bio'],
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      degree: json['degree'],
      university: json['university'],
      subSpecialty: json['subSpecialty'],
      graduationYear: json['graduationYear'],
      boardCertification: json['boardCertification'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      associatedClinics: json['associatedClinics'] != null
          ? List<String>.from(json['associatedClinics'])
          : [],
      qrCodeKey: json['qrCodeKey'],
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
    return DoctorListItem(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      specialization: json['specialization'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      clinicName: json['clinicName'],
      clinicArea: json['clinicArea'],
      isFavorited: json['isFavorited'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
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
    return DoctorSchedule(
      id: json['id'] ?? 0,
      doctorId: json['doctorId'] ?? 0,
      dayOfWeek: dayOfWeekValue,
      dayName: json['dayName'] ?? _dayOfWeekToString(dayOfWeekValue),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      slotDurationMinutes: json['slotDurationMinutes'] ?? 0,
      maxPatients: json['maxPatients'] ?? 0,
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
