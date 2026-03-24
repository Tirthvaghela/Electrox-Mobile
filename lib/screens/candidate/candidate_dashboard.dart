import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../utils/error_handler.dart';
import 'election_results_screen.dart';
import '../../widgets/common/notification_bell.dart';
import '../../widgets/common/shimmer_loader.dart';
import '../profile_screen.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({super.key});

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  final ElectionService _electionService = ElectionService();
  List<Election> _elections = [];
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
      final data = await _electionService.getCandidateElections(auth.userEmail!);
      setState(() {
        _elections = data.map((e) => Election.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed to load: $e');
    }
  }

  int get _active  => _elections.where((e) => e.isActive).length;
  int get _closed  => _elections.where((e) => e.isClosed).length;
  int get _votes   => _elections.fold(0, (s, e) => s + e.totalVotes);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(auth),
            if (_isLoading) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: ShimmerStatGrid(count: 3)),
              ),
              ShimmerList(count: 3),
            ]
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _buildStats()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(child: Row(children: [
                  const Text('My Elections',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy)),
                  const Spacer(),
                  Text('${_elections.length} total',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                ])),
              ),
              if (_elections.isEmpty)
                SliverFillRemaining(child: _buildEmpty())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ElectionCard(
                        election: _elections[i],
                        myEmail: auth.userEmail ?? '',
                        onViewResults: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            ElectionResultsScreen(election: _elections[i]))),
                      ),
                      childCount: _elections.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      automaticallyImplyLeading: false,
      actions: [
        const NotificationBell(),
        IconButton(icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()))),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B2FBE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, Candidate!',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        Text(auth.userName ?? 'Candidate',
                          style: const TextStyle(color: Colors.white, fontSize: 22,
                            fontWeight: FontWeight.w700)),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(auth.userEmail ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final items = [
      ('Active', '$_active', Icons.play_circle_rounded, AppTheme.successGreen),
      ('Completed', '$_closed', Icons.check_circle_rounded, const Color(0xFF4361EE)),
      ('Total Votes', '$_votes', Icons.bar_chart_rounded, const Color(0xFF7B2FBE)),
    ];
    return Row(children: items.map((s) {
      final color = s.$4;
      return Expanded(child: Container(
        margin: EdgeInsets.only(right: s == items.last ? 0 : 10),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Icon(s.$3, size: 22, color: color),
          const SizedBox(height: 6),
          Text(s.$2, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(s.$1, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ]),
      ));
    }).toList());
  }

  Widget _buildEmpty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF7B2FBE).withOpacity(0.1),
          borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.person_outlined, size: 40, color: Color(0xFF7B2FBE))),
      const SizedBox(height: 20),
      const Text('No elections yet',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
      const SizedBox(height: 8),
      const Text('You are not a candidate in any elections yet',
        style: TextStyle(color: AppTheme.textSecondary)),
    ],
  ));
}

// ─── Election Card ────────────────────────────────────────────────────────────

class _ElectionCard extends StatelessWidget {
  final Election election;
  final String myEmail;
  final VoidCallback onViewResults;

  const _ElectionCard({
    required this.election, required this.myEmail, required this.onViewResults});

  Color get _statusColor {
    switch (election.status) {
      case 'active': return AppTheme.successGreen;
      case 'closed': return Colors.grey;
      default: return AppTheme.accentOrange;
    }
  }

  String _fmt(DateTime d) =>
    '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final canSeeResults = election.isActive || election.isClosed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(children: [
        Container(height: 4,
          decoration: BoxDecoration(
            color: _statusColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Expanded(child: Text(election.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(election.statusDisplay.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: _statusColor)),
              ),
            ]),

            if (election.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(election.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],

            const SizedBox(height: 14),

            // Stats
            if (canSeeResults)
              Row(children: [
                _statBox('${election.totalVotes}', 'Total Votes', const Color(0xFF4361EE)),
                const SizedBox(width: 8),
                _statBox('${election.turnoutPercentage.toStringAsFixed(0)}%', 'Turnout', AppTheme.successGreen),
                const SizedBox(width: 8),
                _statBox('${election.candidates.length}', 'Candidates', const Color(0xFF7B2FBE)),
              ])
            else
              Row(children: [
                Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text(
                  election.isDraft
                    ? 'Starts: ${_fmt(election.startDate)}'
                    : 'Ends: ${_fmt(election.endDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: canSeeResults ? onViewResults : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSeeResults
                    ? (election.isClosed ? const Color(0xFF4361EE) : AppTheme.successGreen)
                    : Colors.grey.shade200,
                  foregroundColor: canSeeResults ? Colors.white : Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(canSeeResults
                  ? (election.isClosed ? Icons.bar_chart_rounded : Icons.trending_up_rounded)
                  : Icons.schedule_rounded, size: 18),
                label: Text(
                  election.isClosed ? 'View Final Results'
                  : election.isActive ? 'View Live Results'
                  : 'Election Not Started',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _statBox(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
      ]),
    ),
  );
}
