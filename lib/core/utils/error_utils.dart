import 'package:dio/dio.dart';

/// Extracts a user-friendly error message from an exception.
String errorMessage(Object error) {
  // Handle DioException — extract message from API response body
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return error.message ?? 'Request failed';
  }

  // Strip "Exception: " prefix thrown by `throw Exception('msg')`
  final str = error.toString();
  if (str.startsWith('Exception: ')) {
    return str.substring(11);
  }
  return str;
}
