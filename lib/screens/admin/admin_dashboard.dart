import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../services/admin_service.dart';
import '../../widgets/common/shimmer_loader.dart';
import 'organization_management_screen.dart';
import 'user_management_screen.dart';
import 'audit_logs_screen.dart';
import '../../widgets/common/notification_bell.dart';
import '../profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getStats();
      setState(() { _stats = stats; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            _buildHeader(auth),
              SliverPadding(
              padding: const EdgeInsets.all(AppTheme.paddingScreen),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading) ...[
                    ShimmerStatGrid(count: 6),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle('Management'),
                  const SizedBox(height: 12),
                  _buildManagementCards(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Votes Over Time'),
                  const SizedBox(height: 12),
                  _buildVotesChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('User Distribution'),
                  const SizedBox(height: 12),
                  _buildUsersByRole(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      automaticallyImplyLeading: false,
      actions: [
        const NotificationBell(),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfileScreen())),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            ),
                            Text(
                              auth.userName ?? 'Admin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(auth.userEmail ?? '',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      _StatItem('Total Users',    '${_stats?['total_users'] ?? 0}',               Icons.people_alt_rounded,    const Color(0xFF4361EE)),
      _StatItem('Active Orgs',    '${_stats?['active_organizations'] ?? 0}',      Icons.business_rounded,      AppTheme.successGreen),
      _StatItem('Pending Setup',  '${_stats?['pending_organizations'] ?? 0}',     Icons.hourglass_top_rounded, AppTheme.warningOrange),
      _StatItem('Elections',      '${_stats?['total_elections'] ?? 0}',           Icons.how_to_vote_rounded,   const Color(0xFF7B2FBE)),
      _StatItem('Total Votes',    '${_stats?['total_votes'] ?? 0}',               Icons.check_circle_rounded,  const Color(0xFF06B6D4)),
      _StatItem('Organizers',     '${_stats?['users_by_role']?['organizer'] ?? 0}', Icons.manage_accounts,     AppTheme.accentOrange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildStatCard(items[i]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: item.color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: _isLoading
          ? Center(child: SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: item.color)))
          : Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.value,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: item.color, height: 1)),
                      const SizedBox(height: 3),
                      Text(item.label,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.2),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy));
  }

  Widget _buildManagementCards(BuildContext context) {
    final actions = [
      _ActionItem('Organizations', 'Create & manage orgs', Icons.business_rounded,
        const Color(0xFF4361EE), () async {
          final r = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => const OrganizationManagementScreen()));
          if (r == true) _loadStats();
        }),
      _ActionItem('Users', 'Manage all users', Icons.people_alt_rounded,
        AppTheme.successGreen, () async {
          final r = await Navigator.push(context, MaterialPageRoute(
            builder: (_) => const UserManagementScreen()));
          if (r == true) _loadStats();
        }),
      _ActionItem('Audit Logs', 'View activity logs', Icons.history_rounded,
        const Color(0xFF7B2FBE), () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const AuditLogsScreen()));
        }),
    ];

    return Column(
      children: actions.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildActionCard(a),
      )).toList(),
    );
  }

  Widget _buildActionCard(_ActionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppTheme.softShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildVotesChart() {
    final votesData = _stats?['votes_by_day'] as List<dynamic>?;
    final bars = <BarChartGroupData>[];
    final labels = <String>[];

    if (votesData != null && votesData.isNotEmpty) {
      for (int i = 0; i < votesData.length; i++) {
        final v = (votesData[i]['count'] ?? 0).toDouble();
        final dateStr = votesData[i]['date']?.toString() ?? '';
        // Parse date for label (e.g. "2026-03-16" → "Mar 16")
        String label = '';
        try {
          final d = DateTime.parse(dateStr);
          const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          label = '${m[d.month]} ${d.day}';
        } catch (_) {
          label = dateStr.length >= 5 ? dateStr.substring(5) : dateStr;
        }
        labels.add(label);
        bars.add(BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: v, color: AppTheme.primaryNavy, width: 18,
            borderRadius: BorderRadius.circular(4)),
        ]));
      }
    } else {
      // Placeholder while loading or no data
      final placeholders = [3.0, 7.0, 5.0, 12.0, 8.0, 15.0, 10.0];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (int i = 0; i < placeholders.length; i++) {
        labels.add(days[i]);
        bars.add(BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: placeholders[i],
            color: AppTheme.primaryNavy.withOpacity(0.2),
            width: 18, borderRadius: BorderRadius.circular(4)),
        ]));
      }
    }

    final isPlaceholder = votesData == null || votesData.isEmpty;
    final maxY = bars.isEmpty ? 10.0
        : bars.map((b) => b.barRods.first.toY).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryNavy, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Votes — Last 7 Days',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
          const Spacer(),
          if (isPlaceholder)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('No data', style: TextStyle(fontSize: 10,
                color: AppTheme.accentOrange, fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              maxY: maxY < 1 ? 5 : maxY * 1.2,
              barGroups: bars,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 28,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                )),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 28,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(labels[i],
                        style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    );
                  },
                )),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) {
                    final label = group.x < labels.length ? labels[group.x] : '';
                    return BarTooltipItem(
                      '$label\n${rod.toY.toInt()} votes',
                      const TextStyle(color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildUsersByRole() {
    final roles = _stats?['users_by_role'] as Map<String, dynamic>? ?? {};
    if (roles.isEmpty) return const SizedBox.shrink();

    final roleConfig = {
      'admin':     (_RoleConfig(Icons.admin_panel_settings, const Color(0xFF4361EE))),
      'organizer': (_RoleConfig(Icons.manage_accounts,      AppTheme.accentOrange)),
      'candidate': (_RoleConfig(Icons.person,               const Color(0xFF7B2FBE))),
      'voter':     (_RoleConfig(Icons.how_to_vote,          AppTheme.successGreen)),
    };

    final total = roles.values.fold<int>(0, (s, v) => s + (v as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(
        children: roles.entries.map((e) {
          final cfg = roleConfig[e.key.toLowerCase()];
          final pct = total > 0 ? (e.value as int) / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(cfg?.icon ?? Icons.person, size: 18, color: cfg?.color ?? AppTheme.primaryNavy),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key.toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                    Text('${e.value}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cfg?.color ?? AppTheme.primaryNavy)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(cfg?.color ?? AppTheme.primaryNavy),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSystemStatus() {
    final items = [
      ('Backend API', true),
      ('Database',    true),
      ('Email Service', true),
      ('Scheduler',   true),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(width: 8, height: 8,
                decoration: BoxDecoration(
                  color: item.$2 ? AppTheme.successGreen : AppTheme.errorRed,
                  shape: BoxShape.circle,
                )),
              const SizedBox(width: 12),
              Expanded(child: Text(item.$1,
                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (item.$2 ? AppTheme.successGreen : AppTheme.errorRed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.$2 ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: item.$2 ? AppTheme.successGreen : AppTheme.errorRed)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _ActionItem {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem(this.title, this.subtitle, this.icon, this.color, this.onTap);
}

class _RoleConfig {
  final IconData icon;
  final Color color;
  const _RoleConfig(this.icon, this.color);
}
