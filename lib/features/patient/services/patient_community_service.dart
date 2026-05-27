import '../../../core/constants/app_constants.dart';
import '../../../core/models/community_models.dart';
import '../../../core/services/api_service.dart';

class PatientCommunityService {
  final ApiService _api;
  PatientCommunityService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<CommunityPost>> getPosts({String? specialization}) async {
    final response = await _api.getList(
      ApiEndpoints.communityPosts,
      queryParameters: specialization == null ? null : {'specialization': specialization},
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<CommunityPost> createPost(CreatePostRequest request) async {
    final response = await _api.post(
      ApiEndpoints.communityPosts,
      data: request.toJson(),
      fromJson: (data) => CommunityPost.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<List<CommunityComment>> getComments(int postId) async {
    final response = await _api.getList(
      ApiEndpoints.communityPostComments(postId),
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list.map((e) => CommunityComment.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<CommunityComment> addComment(CreateCommentRequest request) async {
    final response = await _api.post(
      ApiEndpoints.communityPostComments(request.postId),
      data: request.toJson(),
      fromJson: (data) => CommunityComment.fromJson(data as Map<String, dynamic>),
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }
}
