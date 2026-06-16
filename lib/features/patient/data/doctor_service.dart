import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/doctor_models.dart';
import '../../../core/services/api_service.dart';

class DoctorService {
  DoctorService({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<DoctorListItem>> getPopularDoctors() async {
    try {
      final res = await _api.getList<DoctorListItem>(
        ApiEndpoints.popularDoctors,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(DoctorListItem.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getPopularDoctors failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockPopularDoctors;
  }

  Future<List<String>> getSpecializations() async {
    try {
      final res = await _api.getList<String>(
        ApiEndpoints.doctorSpecializations,
        fromJson: (data) => (data as List).map((e) => e.toString()).toList(),
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        return res.data!;
      }
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getSpecializations failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockSpecializations;
  }

  Future<List<DoctorListItem>> browseDoctors({
    String? query,
    String? specialization,
  }) async {
    final qp = <String, dynamic>{
      if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      if (specialization != null && specialization.trim().isNotEmpty)
        'specialization': specialization.trim(),
    };

    try {
      final res = await _api.getList<DoctorListItem>(
        ApiEndpoints.doctors,
        queryParameters: qp.isEmpty ? null : qp,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(DoctorListItem.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('browseDoctors failed: $e');
      if (!useMockDataFallback) rethrow;
    }

    // Mock filter locally.
    final q = query?.toLowerCase().trim();
    return _mockBrowseDoctors.where((d) {
      final matchQ = (q == null || q.isEmpty)
          ? true
          : d.fullName.toLowerCase().contains(q) ||
              d.specialization.toLowerCase().contains(q) ||
              (d.clinicArea ?? '').toLowerCase().contains(q);
      final matchSpec = (specialization == null || specialization.trim().isEmpty)
          ? true
          : d.specialization.toLowerCase() == specialization.toLowerCase().trim();
      return matchQ && matchSpec;
    }).toList();
  }

  Future<DoctorProfile> getDoctorProfile(int id) async {
    try {
      final res = await _api.get<DoctorProfile>(
        ApiEndpoints.doctorDetail(id),
        fromJson: (data) => DoctorProfile.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getDoctorProfile failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockDoctorProfile(id);
  }

  Future<List<DoctorSchedule>> getDoctorSchedules(int doctorId) async {
    try {
      final res = await _api.getList<DoctorSchedule>(
        ApiEndpoints.doctorSchedules(doctorId),
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(DoctorSchedule.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getDoctorSchedules failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return [];
  }

  Future<List<AvailableSlot>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    try {
      final res = await _api.getList<AvailableSlot>(
        ApiEndpoints.doctorAvailableSlots(doctorId),
        queryParameters: {'date': _yyyyMmDd(date)},
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(AvailableSlot.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getAvailableSlots failed: $e');
      if (!useMockDataFallback) rethrow;
    }

    // Mock slots.
    final base = <AvailableSlot>[
      AvailableSlot(time: '09:00 AM', isAvailable: true),
      AvailableSlot(time: '10:30 AM', isAvailable: true),
      AvailableSlot(time: '01:00 PM', isAvailable: true),
      AvailableSlot(time: '03:30 PM', isAvailable: true),
      AvailableSlot(time: '04:00 PM', isAvailable: true),
      AvailableSlot(time: '05:30 PM', isAvailable: false),
    ];
    // Light variability per day.
    final rnd = Random(date.year * 10000 + date.month * 100 + date.day);
    return base
        .map(
          (s) => AvailableSlot(
            time: s.time,
            isAvailable: s.isAvailable && rnd.nextDouble() > 0.15,
          ),
        )
        .toList();
  }

  static String _yyyyMmDd(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

const _mockSpecializations = <String>[
  'Orthopedics',
  'Ophthalmology',
  'Pediatrician',
  'Cardiology',
  'ENT Specialist',
  'Nursing',
  'Pathologist',
  'Dentist',
  'Geriatrician',
  'Neurology',
  'Dermatology',
];

final _mockPopularDoctors = <DoctorListItem>[
  DoctorListItem(
    id: 1,
    fullName: 'Dr.Ahmed',
    specialization: 'Dentist',
    profileImageUrl: null,
    consultationFee: 200,
    averageRating: 3.9,
    totalReviews: 120,
    isAvailable: true,
    clinicName: 'Medicare Clinic',
    clinicArea: 'Maddi',
    isFavorited: false,
  ),
  DoctorListItem(
    id: 2,
    fullName: 'Dr.Mohamed',
    specialization: 'Cardiologist',
    profileImageUrl: null,
    consultationFee: 250,
    averageRating: 3.9,
    totalReviews: 98,
    isAvailable: true,
    clinicName: 'Medicare Clinic',
    clinicArea: 'Maddi',
    isFavorited: false,
  ),
  DoctorListItem(
    id: 3,
    fullName: 'Dr.Alaa',
    specialization: 'Dentist',
    profileImageUrl: null,
    consultationFee: 180,
    averageRating: 3.9,
    totalReviews: 76,
    isAvailable: false,
    clinicName: 'Medicare Clinic',
    clinicArea: 'Maddi',
    isFavorited: false,
  ),
];

final _mockBrowseDoctors = <DoctorListItem>[
  ..._mockPopularDoctors,
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
  DoctorListItem(
    id: 5,
    fullName: 'Dr.Youssef',
    specialization: 'Orthopedics',
    profileImageUrl: null,
    consultationFee: 220,
    averageRating: 4.2,
    totalReviews: 150,
    isAvailable: true,
    clinicName: 'Prime Clinic',
    clinicArea: 'Nasr City',
    isFavorited: false,
  ),
  DoctorListItem(
    id: 6,
    fullName: 'Dr.Nour',
    specialization: 'Dermatology',
    profileImageUrl: null,
    consultationFee: 190,
    averageRating: 4.4,
    totalReviews: 89,
    isAvailable: true,
    clinicName: 'Skin Lab',
    clinicArea: 'Heliopolis',
    isFavorited: false,
  ),
];

DoctorProfile _mockDoctorProfile(int id) {
  return DoctorProfile(
    id: id,
    userId: 1000 + id,
    fullName: 'Dr. Ahmed',
    phoneNumber: '+20 000 000 0000',
    profileImageUrl: null,
    specialization: 'Specialist Dentist',
    consultationFee: 200,
    averageRating: 4.9,
    totalReviews: 2480,
    isAvailable: true,
    yearsOfExperience: 12,
    degree: 'Cairo University',
    university: 'Cairo University',
    graduationYear: 2012,
    boardCertification: 'Egyptian Board',
    languages: const ['Arabic', 'English'],
    associatedClinics: const ['Medicare Clinic'],
    totalPatients: 0,
  );
}
