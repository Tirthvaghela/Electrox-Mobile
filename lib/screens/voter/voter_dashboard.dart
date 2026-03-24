import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../utils/error_handler.dart';
import 'voting_screen.dart';
import '../../widgets/common/notification_bell.dart';
import '../../widgets/common/shimmer_loader.dart';
import '../profile_screen.dart';

class VoterDashboard extends StatefulWidget {
  const VoterDashboard({super.key});

  @override
  State<VoterDashboard> createState() => _VoterDashboardState();
}

class _VoterDashboardState extends State<VoterDashboard> {
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
      final data = await _electionService.getVoterElections(auth.userEmail!);
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
  int get _voted   => _elections.where((e) => e.hasVoted == true).length;
  int get _pending => _elections.where((e) => e.isActive && e.hasVoted != true).length;

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
                sliver: SliverToBoxAdapter(
                  child: ShimmerStatGrid(count: 3),
                ),
              ),
              ShimmerList(count: 3),
            ]
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _buildStats()),
              ),
              if (_pending > 0)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(child: _buildPendingBanner()),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                sliver: SliverToBoxAdapter(child: Row(children: [
                  const Text('Elections',
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
                      (_, i) => _VoterElectionCard(
                        election: _elections[i],
                        onVote: () async {
                          final result = await Navigator.push(context,
                            MaterialPageRoute(builder: (_) =>
                              VotingScreen(election: _elections[i])));
                          if (result == true) _load();
                        },
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
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your voice matters,',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        Text(auth.userName ?? 'Voter',
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
      ('Active', '$_active', Icons.how_to_vote_rounded, const Color(0xFF4361EE)),
      ('Voted', '$_voted', Icons.check_circle_rounded, AppTheme.successGreen),
      ('Pending', '$_pending', Icons.pending_rounded, AppTheme.accentOrange),
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

  Widget _buildPendingBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.notifications_active_rounded, color: AppTheme.accentOrange, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(
          '$_pending election${_pending > 1 ? 's' : ''} waiting for your vote!',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppTheme.accentOrange))),
      ]),
    );
  }

  Widget _buildEmpty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppTheme.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.how_to_vote_outlined, size: 40, color: AppTheme.successGreen)),
      const SizedBox(height: 20),
      const Text('No elections available',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
      const SizedBox(height: 8),
      const Text('You have no elections to vote in right now',
        style: TextStyle(color: AppTheme.textSecondary)),
    ],
  ));
}

// ─── Voter Election Card ──────────────────────────────────────────────────────

class _VoterElectionCard extends StatefulWidget {
  final Election election;
  final VoidCallback onVote;

  const _VoterElectionCard({required this.election, required this.onVote});

  @override
  State<_VoterElectionCard> createState() => _VoterElectionCardState();
}

class _VoterElectionCardState extends State<_VoterElectionCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.election.isActive || widget.election.isDraft) {
      _startTimer();
    }
  }

  void _startTimer() {
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final Duration r;
    if (widget.election.isDraft && widget.election.startDate.isAfter(now)) {
      r = widget.election.startDate.difference(now);
    } else {
      r = widget.election.endDate.toLocal().difference(now);
    }
    setState(() => _remaining = r.isNegative ? Duration.zero : r);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdownText {
    if (_remaining.inSeconds <= 0) return 'Ended';
    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    if (d > 0) return '${d}d ${h}h ${m}m';
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  Election get election => widget.election;

  bool get _canVote => election.canVote && election.hasVoted != true;
  bool get _hasVoted => election.hasVoted == true;

  Color get _statusColor {
    if (_hasVoted) return AppTheme.successGreen;
    if (election.isActive) return const Color(0xFF4361EE);
    if (election.isClosed) return Colors.grey;
    return AppTheme.accentOrange;
  }

  String get _statusLabel {
    if (_hasVoted) return 'VOTED';
    if (election.isActive) return 'ACTIVE';
    if (election.isClosed) return 'CLOSED';
    return 'DRAFT';
  }

  String _fmt(DateTime d) =>
    '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_hasVoted) ...[
                    const Icon(Icons.check_rounded, size: 11, color: AppTheme.successGreen),
                    const SizedBox(width: 3),
                  ],
                  Text(_statusLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: _statusColor)),
                ]),
              ),
            ]),

            if (election.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(election.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],

            const SizedBox(height: 12),

            // Info row
            Row(children: [
              Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('Ends: ${_fmt(election.endDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(width: 14),
              Icon(Icons.person_rounded, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text('${election.candidates.length} candidates',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ]),

            // Countdown chip
            if (election.isActive || (election.isDraft && election.startDate.isAfter(DateTime.now()))) ...[
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final isStarting = election.isDraft;
                final isUrgent = !isStarting && (_remaining.inSeconds <= 0 || _remaining.inHours < 1);
                final color = isStarting
                    ? const Color(0xFF4361EE)
                    : isUrgent ? AppTheme.errorRed : AppTheme.accentOrange;
                final label = isStarting
                    ? (_remaining.inSeconds <= 0 ? 'Starting now…' : 'Starts in $_countdownText')
                    : (_remaining.inSeconds <= 0 ? 'Election Ended' : 'Ends in $_countdownText');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isStarting ? Icons.play_circle_outline_rounded : Icons.timer_rounded,
                        size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(label, style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w600, color: color)),
                  ]),
                );
              }),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _canVote ? widget.onVote : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasVoted
                    ? AppTheme.successGreen
                    : _canVote
                      ? AppTheme.primaryNavy
                      : Colors.grey.shade200,
                  foregroundColor: (_hasVoted || _canVote) ? Colors.white : Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(_hasVoted ? Icons.check_circle_rounded
                  : _canVote ? Icons.how_to_vote_rounded
                  : Icons.lock_rounded, size: 18),
                label: Text(
                  _hasVoted ? 'Vote Submitted'
                  : _canVote ? 'Vote Now'
                  : election.isDraft ? 'Not Started Yet'
                  : 'Election Closed',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
