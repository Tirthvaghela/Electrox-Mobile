import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'local_notification_service.dart';

/// Polls the backend every 30 seconds for new notifications and
/// shows them as device notifications if they haven't been shown before.
class NotificationPoller {
  static Timer? _timer;
  static const _seenKey = 'seen_notification_ids';

  static void start(String email) {
    _timer?.cancel();
    // Poll immediately, then every 30 seconds
    _poll(email);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _poll(email));
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _poll(String email) async {
    try {
      final svc = NotificationService();
      final data = await svc.getNotifications(email);
      final notifications = data['notifications'] as List<dynamic>? ?? [];

      final prefs = await SharedPreferences.getInstance();
      final seen = Set<String>.from(prefs.getStringList(_seenKey) ?? []);

      for (final n in notifications) {
        final id = n['_id']?.toString() ?? '';
        if (id.isEmpty || seen.contains(id)) continue;

        // Show as device notification
        await LocalNotificationService.show(
          id: id.hashCode.abs(),
          title: n['title'] ?? 'Electrox',
          body: n['message'] ?? '',
        );

        seen.add(id);
      }

      await prefs.setStringList(_seenKey, seen.toList());
    } catch (_) {
      // Silently ignore polling errors
    }
  }
}
