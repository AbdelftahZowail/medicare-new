import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  AuthResponse? _currentAuth;
  AuthResponse? get currentAuth => _currentAuth;

  Future<void> initialize() async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    final refresh = await _secureStorage.read(key: StorageKeys.refreshToken);
    final role = await _secureStorage.read(key: StorageKeys.userRole);

    if (token != null && refresh != null) {
      _apiService.setTokens(token, refresh);

      // Reconstruct minimal auth object from storage
      final userId = await _secureStorage.read(key: StorageKeys.userId);
      final profileId = await _secureStorage.read(key: StorageKeys.profileId);
      final userName = await _secureStorage.read(key: StorageKeys.userName);

      _currentAuth = AuthResponse(
        userId: int.tryParse(userId ?? '') ?? 0,
        fullName: userName ?? '',
        phone: '',
        role: role ?? '',
        token: token,
        tokenExpiration: DateTime.now().add(const Duration(hours: 1)),
        refreshToken: refresh,
        refreshTokenExpiration: DateTime.now().add(const Duration(days: 30)),
        profileId: int.tryParse(profileId ?? '') ?? 0,
      );
    }
  }

  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuth(response.data!);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> registerPatient(
    RegisterPatientRequest request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.registerPatient,
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuth(response.data!);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> registerDoctor(
    RegisterDoctorRequest request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.registerDoctor,
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuth(response.data!);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> registerClinic(
    RegisterClinicRequest request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.registerClinic,
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _saveAuth(response.data!);
    }

    return response;
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.logout,
        data: {},
        fromJson: (_) => null,
      );
      await _clearAuth();
      return response;
    } catch (e) {
      await _clearAuth();
      return ApiResponse(
        isSuccess: true,
        message: 'Logged out',
        statusCode: 200,
      );
    }
  }

  Future<ApiResponse<void>> forgotPassword(ForgotPasswordRequest request) async {
    return await _apiService.post(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
      fromJson: (_) => null,
    );
  }

  Future<ApiResponse<void>> verifyOtp(VerifyOtpRequest request) async {
    return await _apiService.post(
      ApiEndpoints.verifyOtp,
      data: request.toJson(),
      fromJson: (_) => null,
    );
  }

  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    return await _apiService.post(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
      fromJson: (_) => null,
    );
  }

  Future<void> _saveAuth(AuthResponse auth) async {
    _currentAuth = auth;
    _apiService.setTokens(auth.token, auth.refreshToken);

    await _secureStorage.write(key: StorageKeys.accessToken, value: auth.token);
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: auth.refreshToken,
    );
    await _secureStorage.write(key: StorageKeys.userRole, value: auth.role);
    await _secureStorage.write(
      key: StorageKeys.userId,
      value: auth.userId.toString(),
    );
    await _secureStorage.write(
      key: StorageKeys.profileId,
      value: auth.profileId.toString(),
    );
    await _secureStorage.write(key: StorageKeys.userName, value: auth.fullName);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isFirstTime, false);
  }

  Future<void> _clearAuth() async {
    _currentAuth = null;
    await _apiService.clearTokens();

    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userRole);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.profileId);
    await _secureStorage.delete(key: StorageKeys.userName);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: StorageKeys.userRole);
  }

  Future<int?> getUserId() async {
    final id = await _secureStorage.read(key: StorageKeys.userId);
    return id != null ? int.tryParse(id) : null;
  }

  Future<int?> getProfileId() async {
    final id = await _secureStorage.read(key: StorageKeys.profileId);
    return id != null ? int.tryParse(id) : null;
  }
}
