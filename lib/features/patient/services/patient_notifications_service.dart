import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/shared_models.dart';
import '../../../core/services/api_service.dart';

class PatientNotificationsService {
  final ApiService _api;
  PatientNotificationsService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<NotificationItem>> getNotifications() async {
    final response = await _api.getList(
      ApiEndpoints.notifications,
      fromJson: (data) {
        final list = (data as List).cast<dynamic>();
        return list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  Future<ApiResponse<void>> markAsRead(int notificationId) {
    return _api.put(
      ApiEndpoints.markNotificationRead(notificationId),
      data: {},
      fromJson: (_) => null,
    );
  }
}
