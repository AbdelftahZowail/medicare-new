import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.apiBase,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          // Set JSON content-type for JSON payloads; skip for FormData (multipart)
          if (options.data is! FormData) {
            options.contentType = 'application/json';
          }
          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.path}');
            print('HEADERS: ${options.headers}');
            print('DATA: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE: ${response.statusCode} ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('ERROR: ${error.response?.statusCode} ${error.message}');
          }

          // Handle 401 - Token expired
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            try {
              final refreshed = await _refreshAccessToken();
              if (refreshed) {
                // Retry original request
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $_accessToken';
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // Refresh failed, clear tokens
              await clearTokens();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': _refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponse.fromJson(data),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final auth = apiResponse.data!;
          setTokens(auth.token, auth.refreshToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // HTTP Methods
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  Future<ApiResponse<List<T>>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required List<T> Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    final json = response.data as Map<String, dynamic>;
    return ApiResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.put(path, data: data);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.delete(path);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  // Upload file
  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(path, data: formData);
    return ApiResponse.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Dio get dio => _dio;
}
