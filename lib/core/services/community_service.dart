import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/community_models.dart';
import 'api_service.dart';

class CommunityService {
  CommunityService({ApiService? apiService}) : _api = apiService ?? ApiService();
  final ApiService _api;

  Future<List<CommunityPost>> getPosts({String? specialization}) async {
    try {
      final res = await _api.getList<CommunityPost>(
        ApiEndpoints.communityPosts,
        queryParameters: specialization != null ? {'specialization': specialization} : null,
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(CommunityPost.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('getPosts failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockPosts;
  }

  Future<CommunityPost> createPost(CreatePostRequest request) async {
    try {
      final res = await _api.post<CommunityPost>(
        ApiEndpoints.communityPosts,
        data: request.toJson(),
        fromJson: (data) => CommunityPost.fromJson(data as Map<String, dynamic>),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('createPost failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockPosts.first;
  }

  Future<List<CommunityComment>> getComments(int postId) async {
    try {
      final res = await _api.getList<CommunityComment>(
        ApiEndpoints.communityPostComments(postId),
        fromJson: (data) {
          final list = (data as List).cast<Map<String, dynamic>>();
          return list.map(CommunityComment.fromJson).toList();
        },
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (e) {
      if (kDebugMode) debugPrint('getComments failed: $e');
      if (!useMockDataFallback) rethrow;
    }
    return _mockComments;
  }

  Future<void> addComment(CreateCommentRequest request) async {
    try {
      await _api.post<dynamic>(
        ApiEndpoints.communityPostComments(request.postId),
        data: request.toJson(),
        fromJson: (_) => null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('addComment failed: $e');
    }
  }
}

final _mockPosts = <CommunityPost>[
  CommunityPost(
    id: 1,
    userId: 1,
    authorName: 'Khaled Ayman',
    authorRoleText: 'Patient',
    content: 'I need a good pediatrician for my son. Can anyone recommend a doctor they have visited before on this app?',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    commentsCount: 5,
    comments: [],
  ),
  CommunityPost(
    id: 2,
    userId: 2,
    authorName: 'Sara Ahmed',
    authorRoleText: 'Patient',
    content: 'What are the best clinics for dental care in Cairo? Looking for recommendations.',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    commentsCount: 3,
    comments: [],
  ),
];

final _mockComments = <CommunityComment>[
  CommunityComment(
    id: 1,
    postId: 1,
    userId: 3,
    authorName: 'Dr. Mohamed',
    authorRoleText: 'Doctor',
    content: 'I recommend Dr. Ahmed at Medicare Clinic. He is very experienced with children.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  CommunityComment(
    id: 2,
    postId: 1,
    userId: 4,
    authorName: 'Fatima Ali',
    authorRoleText: 'Patient',
    content: 'Thank you! I will book an appointment with him.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];
