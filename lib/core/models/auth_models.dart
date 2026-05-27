class AuthResponse {
  final int userId;
  final String fullName;
  final String phone;
  final String role;
  final String token;
  final DateTime tokenExpiration;
  final String refreshToken;
  final DateTime refreshTokenExpiration;
  final int profileId;

  AuthResponse({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.token,
    required this.tokenExpiration,
    required this.refreshToken,
    required this.refreshTokenExpiration,
    required this.profileId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      tokenExpiration: json['tokenExpiration'] != null
          ? DateTime.parse(json['tokenExpiration'])
          : DateTime.now(),
      refreshToken: json['refreshToken'] ?? '',
      refreshTokenExpiration: json['refreshTokenExpiration'] != null
          ? DateTime.parse(json['refreshTokenExpiration'])
          : DateTime.now(),
      profileId: json['profileId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'token': token,
      'tokenExpiration': tokenExpiration.toIso8601String(),
      'refreshToken': refreshToken,
      'refreshTokenExpiration': refreshTokenExpiration.toIso8601String(),
      'profileId': profileId,
    };
  }
}

class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  Map<String, dynamic> toJson() => {'phone': phone, 'password': password};
}

class RegisterPatientRequest {
  final String name;
  final String phone;
  final String password;
  final String confirmPassword;
  final int? age;

  RegisterPatientRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.age,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        if (age != null) 'age': age,
      };
}

class RegisterDoctorRequest {
  final String name;
  final String phone;
  final String password;
  final String confirmPassword;
  final String specialization;
  final String? licenseFileUrl;

  RegisterDoctorRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.specialization,
    this.licenseFileUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'specialization': specialization,
        if (licenseFileUrl != null) 'licenseFileUrl': licenseFileUrl,
      };
}

class RegisterClinicRequest {
  final String clinicName;
  final String phone;
  final String password;
  final String confirmPassword;
  final String? government;
  final String? area;
  final String? licenseFileUrl;

  RegisterClinicRequest({
    required this.clinicName,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.government,
    this.area,
    this.licenseFileUrl,
  });

  Map<String, dynamic> toJson() => {
        'clinicName': clinicName,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        if (government != null) 'government': government,
        if (area != null) 'area': area,
        if (licenseFileUrl != null) 'licenseFileUrl': licenseFileUrl,
      };
}

class ForgotPasswordRequest {
  final String phone;
  ForgotPasswordRequest({required this.phone});
  Map<String, dynamic> toJson() => {'phone': phone};
}

class VerifyOtpRequest {
  final String phone;
  final String otpCode;
  VerifyOtpRequest({required this.phone, required this.otpCode});
  Map<String, dynamic> toJson() => {'phone': phone, 'otpCode': otpCode};
}

class ResetPasswordRequest {
  final String phone;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.phone,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otpCode': otpCode,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}

class RefreshTokenRequest {
  final String refreshToken;
  RefreshTokenRequest({required this.refreshToken});
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
