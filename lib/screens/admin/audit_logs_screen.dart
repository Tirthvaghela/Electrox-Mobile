import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../config/theme.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _error;
  int _limit = 50;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final logs = await _adminService.getAuditLogs(limit: _limit);
      setState(() { _logs = logs; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Color _actionColor(String a) {
    switch (a.toLowerCase()) {
      case 'user_login': return AppTheme.successGreen;
      case 'user_logout': return AppTheme.warningOrange;
      case 'user_created':
      case 'account_setup_completed': return const Color(0xFF4361EE);
      case 'election_created': return const Color(0xFF7B2FBE);
      case 'vote_cast': return AppTheme.successGreen;
      case 'organization_created': return AppTheme.accentOrange;
      case 'invitation_sent': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _actionIcon(String a) {
    switch (a.toLowerCase()) {
      case 'user_login': return Icons.login_rounded;
      case 'user_logout': return Icons.logout_rounded;
      case 'user_created': return Icons.person_add_rounded;
      case 'account_setup_completed': return Icons.check_circle_rounded;
      case 'election_created': return Icons.how_to_vote_rounded;
      case 'vote_cast': return Icons.check_box_rounded;
      case 'organization_created': return Icons.business_rounded;
      case 'invitation_sent': return Icons.mail_rounded;
      default: return Icons.info_rounded;
    }
  }

  String _formatAction(String a) =>
    a.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else if (_logs.isEmpty)
              SliverFillRemaining(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _LogCard(
                      log: _logs[i],
                      color: _actionColor(_logs[i]['action'] ?? ''),
                      icon: _actionIcon(_logs[i]['action'] ?? ''),
                      formatAction: _formatAction,
                      timeAgo: _timeAgo,
                    ),
                    childCount: _logs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          onSelected: (v) { setState(() => _limit = v); _load(); },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 25, child: Text('Last 25')),
            PopupMenuItem(value: 50, child: Text('Last 50')),
            PopupMenuItem(value: 100, child: Text('Last 100')),
            PopupMenuItem(value: 200, child: Text('Last 200')),
          ],
        ),
        IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF0D1B2E), AppTheme.primaryNavy],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFF7B2FBE), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Audit Logs',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      Text('${_logs.length} entries · last $_limit',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ]),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
      const SizedBox(height: 16),
      Text(_error!, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ],
  ));

  Widget _buildEmpty() => const Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.history_rounded, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('No audit logs yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
    ],
  ));
}

// ─── Log Card ─────────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final Color color;
  final IconData icon;
  final String Function(String) formatAction;
  final String Function(DateTime) timeAgo;

  const _LogCard({
    required this.log, required this.color, required this.icon,
    required this.formatAction, required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final action = log['action'] ?? 'unknown';
    final email = log['user_email'] ?? 'Unknown';
    final ip = log['ip_address'] ?? '';
    final ts = DateTime.tryParse(log['timestamp'] ?? '');
    final details = log['details'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(formatAction(action),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(email,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4361EE), fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(ts != null ? timeAgo(ts) : '—',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if (ip.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.router_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(ip, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ]),
            ],
          ),
          children: details.isEmpty ? [] : [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  ...details.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(width: 110, child: Text('${e.key}:',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary))),
                      Expanded(child: Text(e.value.toString(),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
                    ]),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
