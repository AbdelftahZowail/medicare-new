import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final ApiService _api = ApiService();

  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  Future<String?> getStoredToken() async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.fcmToken,
      fromJson: (d) => d as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!['token'] as String?;
    }
    return null;
  }

  Future<void> registerToken(String token) async {
    await _api.post(
      ApiEndpoints.registerFcmToken,
      data: {'token': token},
      fromJson: (_) => null,
    );
  }

  Future<void> deleteToken() async {
    try {
      await _api.delete(ApiEndpoints.registerFcmToken, fromJson: (_) => null);
    } catch (_) {
      // Non-blocking — token deletion isn't critical
    }
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await requestPermission();

    // Listen for token refresh — registerToken silently
    // fails if unauthenticated (safe for background refreshes)
    messaging.onTokenRefresh.listen((newToken) {
      try {
        registerToken(newToken);
      } catch (_) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground push handler
    });
  }
}
