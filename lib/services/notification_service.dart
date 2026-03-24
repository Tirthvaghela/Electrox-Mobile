import 'api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  // Backend registers at /api/notifications (plural)
  static const _base = '/notifications';

  Future<Map<String, dynamic>> getNotifications(String email) async {
    final res = await _api.get('$_base/my-notifications', queryParameters: {'email': email});
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to load notifications');
  }

  Future<int> getUnreadCount(String email) async {
    try {
      final res = await _api.get('$_base/unread-count', queryParameters: {'email': email});
      if (res.statusCode == 200) return res.data['unread_count'] ?? 0;
    } catch (_) {}
    return 0;
  }

  Future<void> markRead(String notificationId) async {
    await _api.put('$_base/mark-read/$notificationId');
  }

  Future<void> markAllRead(String email) async {
    await _api.put('$_base/mark-all-read', data: {'email': email});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _api.delete('$_base/$notificationId');
  }

  Future<void> clearAll(String email) async {
    await _api.delete('$_base/clear-all/$email');
  }
}
