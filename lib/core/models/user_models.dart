class User {
  final int id;
  final String fullName;
  final String phone;
  final String email;
  final int role;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 0,
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

class PatientProfile {
  final int id;
  final int userId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final int? gender;
  final int? age;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final String? address;
  final String? bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  PatientProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.gender,
    this.age,
    this.dateOfBirth,
    this.profileImageUrl,
    this.address,
    this.bloodType,
    this.allergies,
    this.chronicDiseases,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    // Parse gender: backend sends string ("Male"/"Female") but Dart model uses int (0/1)
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

    return PatientProfile(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      gender: _parseGender(json['gender']),
      age: json['age'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      bloodType: json['bloodType'],
      allergies: json['allergies'],
      chronicDiseases: json['chronicDiseases'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'gender': gender,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'address': address,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }
}
