import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/clinic_models.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/services/api_service.dart';

class NearbyService {
  NearbyService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<ClinicProfile>> getNearbyClinics({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    try {
      final res = await _api.getList<ClinicProfile>(
        ApiEndpoints.nearbyClinics(lat, lng, radiusKm: radiusKm),
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(ClinicProfile.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getNearbyClinics failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockNearbyClinics;
  }

  Future<List<DoctorListItem>> getNearbyDoctors({
    required double lat,
    required double lng,
    double radiusKm = 10,
    String? specialization,
  }) async {
    final qp = <String, dynamic>{
      if (specialization != null && specialization.trim().isNotEmpty)
        'specialization': specialization.trim(),
    };

    try {
      final res = await _api.getList<DoctorListItem>(
        ApiEndpoints.nearbyDoctors(lat, lng, radiusKm: radiusKm),
        queryParameters: qp.isEmpty ? null : qp,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(DoctorListItem.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getNearbyDoctors failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockNearbyDoctors;
  }
}

final _mockNearbyClinics = <ClinicProfile>[
  ClinicProfile(
    id: 1,
    name: 'Medicare Clinic',
    address: '123 Health St, Maddi',
    phoneNumber: '+20 2 1234 5678',
    email: 'info@medicare.com',
    latitude: 30.0444,
    longitude: 31.2357,
    openingTime: '09:00',
    closingTime: '21:00',
    isActive: true,
    doctorsCount: 12,
  ),
  ClinicProfile(
    id: 2,
    name: 'Nile Health Center',
    address: '45 Nile Corniche, Dokki',
    phoneNumber: '+20 2 8765 4321',
    email: 'contact@nilehealth.com',
    latitude: 30.0461,
    longitude: 31.2109,
    openingTime: '08:00',
    closingTime: '22:00',
    isActive: true,
    doctorsCount: 8,
  ),
  ClinicProfile(
    id: 3,
    name: 'Prime Clinic',
    address: '77 Nasr Rd, Nasr City',
    phoneNumber: '+20 2 5555 9999',
    email: 'hello@primeclinic.com',
    latitude: 30.0626,
    longitude: 31.2769,
    openingTime: '10:00',
    closingTime: '20:00',
    isActive: true,
    doctorsCount: 5,
  ),
];

final _mockNearbyDoctors = <DoctorListItem>[
  DoctorListItem(
    id: 1,
    fullName: 'Dr. Ahmed Hassan',
    specialization: 'Dentistry',
    profileImageUrl: null,
    consultationFee: 200,
    averageRating: 4.8,
    totalReviews: 120,
    isAvailable: true,
    clinicName: 'Medicare Clinic',
    clinicArea: 'Maddi',
    isFavorited: false,
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  DoctorListItem(
    id: 2,
    fullName: 'Dr. Sara Mohamed',
    specialization: 'Cardiology',
    profileImageUrl: null,
    consultationFee: 300,
    averageRating: 4.6,
    totalReviews: 210,
    isAvailable: true,
    clinicName: 'Nile Health Center',
    clinicArea: 'Dokki',
    isFavorited: true,
    latitude: 30.0461,
    longitude: 31.2109,
  ),
  DoctorListItem(
    id: 3,
    fullName: 'Dr. Youssef Ali',
    specialization: 'Orthopedics',
    profileImageUrl: null,
    consultationFee: 250,
    averageRating: 4.2,
    totalReviews: 150,
    isAvailable: false,
    clinicName: 'Prime Clinic',
    clinicArea: 'Nasr City',
    isFavorited: false,
    latitude: 30.0626,
    longitude: 31.2769,
  ),
];
