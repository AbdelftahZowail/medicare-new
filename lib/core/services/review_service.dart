import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/shared_models.dart';
import 'api_service.dart';

class ReviewService {
  ReviewService({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;

  Future<void> submitReview({
    required int doctorId,
    required int appointmentId,
    required double rating,
    String? comment,
  }) async {
    try {
      await _api.post<dynamic>(
        ApiEndpoints.reviews,
        data: {
          'doctorId': doctorId,
          'appointmentId': appointmentId,
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
        fromJson: (_) => null,
      );
    } catch (e) {
      if (kEnableDebugTools) debugPrint('submitReview failed: $e');
    }
  }

  Future<List<Review>> getDoctorReviews(int doctorId) async {
    try {
      final res = await _api.getList<Review>(
        ApiEndpoints.doctorReviews(doctorId),
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(Review.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kEnableDebugTools) debugPrint('getDoctorReviews failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockReviews;
  }
}

final _mockReviews = <Review>[
  Review(
    id: 1,
    doctorId: 1,
    patientId: 1,
    patientName: 'Ahmed Ali',
    rating: 5.0,
    comment: 'Excellent doctor, very professional and caring.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Review(
    id: 2,
    doctorId: 1,
    patientId: 2,
    patientName: 'Fatima Hassan',
    rating: 4.5,
    comment: 'Great experience, would recommend.',
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
];
