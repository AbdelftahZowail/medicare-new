class CommunityPost {
  final int id;
  final int userId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String authorRoleText;
  final String? authorSpecialization;
  final String content;
  final String? specialization;
  final DateTime createdAt;
  final int commentsCount;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.authorRoleText,
    this.authorSpecialization,
    required this.content,
    this.specialization,
    required this.createdAt,
    required this.commentsCount,
    required this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      authorName: json['authorName'] ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'],
      authorRoleText: json['authorRoleText'] ?? '',
      authorSpecialization: json['authorSpecialization'],
      content: json['content'] ?? '',
      specialization: json['specialization'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      commentsCount: json['commentsCount'] ?? 0,
      comments: json['comments'] != null
          ? List<CommunityComment>.from(
              json['comments'].map((x) => CommunityComment.fromJson(x)),
            )
          : [],
    );
  }
}

class CommunityComment {
  final int id;
  final int postId;
  final int userId;
  final String authorName;
  final String? authorProfileImageUrl;
  final String authorRoleText;
  final String content;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorName,
    this.authorProfileImageUrl,
    required this.authorRoleText,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      userId: json['userId'] ?? 0,
      authorName: json['authorName'] ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'],
      authorRoleText: json['authorRoleText'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class CreatePostRequest {
  final String content;
  final String? specialization;

  CreatePostRequest({required this.content, this.specialization});

  Map<String, dynamic> toJson() => {
        'content': content,
        if (specialization != null) 'specialization': specialization,
      };
}

class CreateCommentRequest {
  final int postId;
  final String content;

  CreateCommentRequest({required this.postId, required this.content});

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'content': content,
      };
}
