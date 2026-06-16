import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/doctor_models.dart';
import '../models/shared_models.dart';
import '../models/user_models.dart';
import 'api_service.dart';

class PatientService {
  PatientService({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;

  Future<PatientProfile> getProfile() async {
    try {
      final res = await _api.get<PatientProfile>(
        ApiEndpoints.patientProfile,
        fromJson: (data) => PatientProfile.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getProfile failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: PatientService.getProfile returning mock data');
    return _mockProfile;
  }

  Future<PatientProfile> updateProfile(PatientProfile profile) async {
    try {
      final res = await _api.put<PatientProfile>(
        ApiEndpoints.patientProfile,
        data: profile.toJson(),
        fromJson: (data) => PatientProfile.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('updateProfile failed: $e');
    }
    return profile;
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      final res = await _api.getList<FamilyMember>(
        ApiEndpoints.patientFamilyMembers,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(FamilyMember.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getFamilyMembers failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: PatientService.getFamilyMembers returning mock data');
    return _mockFamilyMembers;
  }

  Future<FamilyMember> addFamilyMember(FamilyMember member) async {
    try {
      final res = await _api.post<FamilyMember>(
        ApiEndpoints.patientFamilyMembers,
        data: member.toJson(),
        fromJson: (data) => FamilyMember.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('addFamilyMember failed: $e');
    }
    return member;
  }

  Future<void> removeFamilyMember(int memberId) async {
    try {
      await _api.delete<dynamic>(
        ApiEndpoints.deleteFamilyMember(memberId),
        fromJson: (_) => null,
      );
    } catch (e) {
      if (kEnableDebugTools) debugPrint('removeFamilyMember failed: $e');
    }
  }

  Future<List<NotificationItem>> getNotifications() async {
    try {
      final res = await _api.getList<NotificationItem>(
        ApiEndpoints.notifications,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(NotificationItem.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getNotifications failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: PatientService.getNotifications returning mock data');
    return _mockNotifications;
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await _api.put<dynamic>(
        ApiEndpoints.markNotificationRead(id),
        data: {},
        fromJson: (_) => null,
      );
    } catch (e) {
      if (kEnableDebugTools) debugPrint('markNotificationRead failed: $e');
    }
  }

  Future<List<DoctorListItem>> getFavorites() async {
    try {
      final res = await _api.getList<DoctorListItem>(
        ApiEndpoints.patientFavorites,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(DoctorListItem.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getFavorites failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    debugPrint('⚠️ MOCK FALLBACK: PatientService.getFavorites returning mock data');
    return _mockFavorites;
  }

  Future<void> favoriteToggle(int doctorId) async {
    await _api.post<dynamic>(
      ApiEndpoints.patientFavorite(doctorId),
      data: {},
      fromJson: (_) => null,
    );
  }
}

final _mockProfile = PatientProfile(
  id: 1,
  userId: 1,
  fullName: 'Ahmed Ali',
  phoneNumber: '+20 100 123 4567',
  email: 'ahmed@gmail.com',
  gender: 0,
  age: 26,
  dateOfBirth: DateTime(1998, 5, 15),
  profileImageUrl: null,
  address: 'Maddi, Cairo',
  bloodType: 'B+',
  allergies: 'None',
  chronicDiseases: 'None',
  emergencyContactName: 'Omar Ali',
  emergencyContactPhone: '+20 100 987 6543',
);

final _mockFamilyMembers = <FamilyMember>[
  FamilyMember(
    id: 1,
    patientId: 1,
    name: 'Ahmed (Me)',
    relation: 0,
    age: 42,
    gender: 0,
    bloodType: 'B+',
  ),
  FamilyMember(
    id: 2,
    patientId: 1,
    name: 'Sarah',
    relation: 2,
    age: 39,
    gender: 1,
    bloodType: 'A+',
  ),
  FamilyMember(
    id: 3,
    patientId: 1,
    name: 'Omar',
    relation: 1,
    age: 10,
    gender: 0,
    bloodType: 'O+',
  ),
];

final _mockNotifications = <NotificationItem>[
  NotificationItem(
    id: 1,
    title: 'Appointment Confirmed',
    message: 'Your appointment with Dr. Ahmed has been confirmed for tomorrow at 4 PM.',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NotificationItem(
    id: 2,
    title: 'Appointment Reminder',
    message: 'You have an appointment with Dr. Mohamed in 1 hour.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final _mockFavorites = <DoctorListItem>[
  DoctorListItem(
    id: 4,
    fullName: 'Dr.Sara',
    specialization: 'Neurology',
    profileImageUrl: null,
    consultationFee: 300,
    averageRating: 4.6,
    totalReviews: 210,
    isAvailable: true,
    clinicName: 'Nile Health',
    clinicArea: 'Dokki',
    isFavorited: true,
  ),
];
