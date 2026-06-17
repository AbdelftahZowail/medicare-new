import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import '../constants/app_constants.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final ApiService _api = ApiService();

  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

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

    // Request notification permissions
    await requestPermission();

    // Get and register initial token
    final token = await getToken();
    if (token != null) {
      await registerToken(token);
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) {
      registerToken(newToken);
    });

    // Handle foreground messages (optional — for now just log)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // This fires when the app is in the foreground.
      // In the future, show a local notification or snackbar here.
    });
  }
}
