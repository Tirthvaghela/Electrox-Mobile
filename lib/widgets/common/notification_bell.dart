import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../screens/notifications_screen.dart';

/// App bar notification bell with unread badge.
/// Refreshes count on mount and after returning from NotificationsScreen.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _service = NotificationService();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _fetchCount();
  }

  Future<void> _fetchCount() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userEmail == null) return;
      final count = await _service.getUnreadCount(auth.userEmail!);
      if (mounted) setState(() => _unread = count);
    } catch (_) {}
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // Refresh count after returning
    _fetchCount();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: _open,
        ),
        if (_unread > 0)
          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCA311),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
