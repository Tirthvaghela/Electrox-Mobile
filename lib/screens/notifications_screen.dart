import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await _service.getNotifications(auth.userEmail!);
      setState(() {
        _notifications = data['notifications'] ?? [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await _service.markAllRead(auth.userEmail!);
      setState(() {
        for (final n in _notifications) n['read'] = true;
      });
    } catch (_) {}
  }

  Future<void> _markRead(dynamic n) async {
    if (n['read'] == true) return;
    try {
      await _service.markRead(n['_id']);
      setState(() => n['read'] = true);
    } catch (_) {}
  }

  Future<void> _deleteNotification(dynamic n) async {
    try {
      await _service.deleteNotification(n['_id']);
      setState(() => _notifications.remove(n));
    } catch (_) {}
  }

  Future<void> _clearAll() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _service.clearAll(auth.userEmail!);
      setState(() => _notifications.clear());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => n['read'] != true).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (unread > 0)
                TextButton(
                  onPressed: _markAllRead,
                  child: const Text('Mark all read',
                      style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
                ),
              if (_notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
                  tooltip: 'Clear all',
                  onPressed: _clearAll,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications, color: AppTheme.accentOrange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Notifications',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                            if (unread > 0)
                              Text('$unread unread',
                                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
                          ]),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryNavy)),
            )
          else if (_notifications.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildNotificationCard(_notifications[i]),
                  childCount: _notifications.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic n) {
    final isRead = n['read'] == true;
    final type = n['type'] ?? 'info';

    final Color typeColor;
    final IconData typeIcon;
    switch (type) {
      case 'success':
        typeColor = AppTheme.successGreen;
        typeIcon = Icons.check_circle_outline;
        break;
      case 'warning':
        typeColor = AppTheme.accentOrange;
        typeIcon = Icons.warning_amber_outlined;
        break;
      case 'error':
        typeColor = AppTheme.errorRed;
        typeIcon = Icons.error_outline;
        break;
      default:
        typeColor = AppTheme.primaryNavy;
        typeIcon = Icons.info_outline;
    }

    return Dismissible(
      key: Key(n['_id']?.toString() ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(n),
      child: GestureDetector(
        onTap: () => _markRead(n),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: const [AppTheme.softShadow],
            border: isRead ? null : Border.all(color: typeColor.withOpacity(0.3), width: 1.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(n['title'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ))),
                if (!isRead)
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(n['message'] ?? '',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Text(_timeAgo(n['created_at']),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textHint, fontSize: 11)),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_none, size: 48, color: AppTheme.primaryNavy),
        ),
        const SizedBox(height: 16),
        const Text('No notifications', style: AppTheme.headlineMedium),
        const SizedBox(height: 8),
        Text("You're all caught up!", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
      ]),
    );
  }

  String _timeAgo(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
