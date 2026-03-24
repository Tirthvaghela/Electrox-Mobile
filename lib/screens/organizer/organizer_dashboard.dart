import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../utils/error_handler.dart';
import 'create_election_screen.dart';
import 'election_details_screen.dart';
import '../../widgets/common/notification_bell.dart';
import '../../widgets/common/shimmer_loader.dart';
import '../profile_screen.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final ElectionService _electionService = ElectionService();
  List<Election> _elections = [];
  List<Election> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _filtered = _elections.where((e) {
        final matchSearch = _searchQuery.isEmpty ||
            e.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchStatus = _statusFilter == 'all' || e.status == _statusFilter;
        return matchSearch && matchStatus;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await _electionService.getMyElections(auth.userEmail!);
      setState(() {
        _elections = data.map((e) => Election.fromJson(e)).toList();
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // ── computed stats ──
  int get _draft   => _elections.where((e) => e.isDraft).length;
  int get _active  => _elections.where((e) => e.isActive).length;
  int get _closed  => _elections.where((e) => e.isClosed).length;
  int get _votes   => _elections.fold(0, (s, e) => s + e.totalVotes);
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goCreate,
        backgroundColor: AppTheme.accentOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Election',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(auth),
            if (_isLoading) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: ShimmerStatGrid()),
              ),
              ShimmerList(count: 3),
            ]
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _buildStatsGrid()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _buildSearchBar()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _buildSectionTitle()),
              ),
              if (_filtered.isEmpty)
                SliverToBoxAdapter(child: _elections.isEmpty ? _buildEmpty() : _buildNoResults())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ElectionCard(
                        election: _filtered[i],
                        onTap: () => _goDetails(_filtered[i]),
                        onActivate: () => _activate(_filtered[i]),
                        onClose: () => _close(_filtered[i]),
                        onDelete: () => _delete(_filtered[i]),
                      ),
                      childCount: _filtered.length,
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
                        color: AppTheme.accentOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        Text(auth.userName ?? 'Organizer',
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

  Widget _buildStatsGrid() {
    final items = [
      _Stat('Total', '${_elections.length}', Icons.how_to_vote_rounded, const Color(0xFF4361EE)),
      _Stat('Active', '$_active', Icons.play_circle_rounded, AppTheme.successGreen),
      _Stat('Draft', '$_draft', Icons.edit_rounded, AppTheme.accentOrange),
      _Stat('Votes', '$_votes', Icons.check_circle_rounded, const Color(0xFF7B2FBE)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.7),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final s = items[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: s.color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: s.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(s.icon, color: s.color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: s.color, height: 1)),
                const SizedBox(height: 2),
                Text(s.label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            )),
          ]),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) { _searchQuery = v; _applyFilter(); },
          decoration: InputDecoration(
            hintText: 'Search elections…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _statusFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'closed', child: Text('Closed')),
            ],
            onChanged: (v) { setState(() => _statusFilter = v!); _applyFilter(); },
          ),
        ),
      ),
    ]);
  }

  Widget _buildNoResults() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textHint),
      const SizedBox(height: 16),
      const Text('No elections match your search',
        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () {
          _searchCtrl.clear();
          setState(() { _searchQuery = ''; _statusFilter = 'all'; });
          _applyFilter();
        },
        child: const Text('Clear filters'),
      ),
    ],
  ));

  Widget _buildSectionTitle() {
    return Row(children: [
      const Text('My Elections',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
      const Spacer(),
      Text('${_filtered.length} of ${_elections.length}',
        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
    ]);
  }

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
      const SizedBox(height: 16),
      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ]),
  ));

  Widget _buildEmpty() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppTheme.accentOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.how_to_vote_outlined, size: 40, color: AppTheme.accentOrange),
      ),
      const SizedBox(height: 20),
      const Text('No elections yet',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
      const SizedBox(height: 8),
      const Text('Create your first election to get started',
        style: TextStyle(color: AppTheme.textSecondary)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _goCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Election'),
      ),
    ],
  ));

  Future<void> _goCreate() async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => const CreateElectionScreen()));
    if (result == true) _load();
  }

  Future<void> _goDetails(Election e) async {
    final result = await Navigator.push(context,
      MaterialPageRoute(builder: (_) => ElectionDetailsScreen(election: e)));
    if (result == true) _load();
  }

  Future<void> _activate(Election e) async {
    final ok = await ErrorHandler.showConfirmationDialog(context,
      'Activate Election',
      'Activate "${e.title}"? Voters will be notified.',
      confirmText: 'Activate', confirmColor: AppTheme.successGreen);
    if (!ok) return;
    try {
      await _electionService.updateElectionStatus(e.id, 'active');
      if (mounted) { ErrorHandler.showSuccessSnackBar(context, 'Election activated!'); _load(); }
    } catch (err) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $err');
    }
  }

  Future<void> _close(Election e) async {
    final ok = await ErrorHandler.showConfirmationDialog(context,
      'Close Election', 'Close "${e.title}"? No more votes can be cast.',
      confirmText: 'Close', confirmColor: AppTheme.errorRed);
    if (!ok) return;
    try {
      await _electionService.updateElectionStatus(e.id, 'closed');
      if (mounted) { ErrorHandler.showSuccessSnackBar(context, 'Election closed!'); _load(); }
    } catch (err) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $err');
    }
  }

  Future<void> _delete(Election e) async {
    final ok = await ErrorHandler.showConfirmationDialog(context,
      'Delete Election', 'Delete "${e.title}"? This cannot be undone.',
      confirmText: 'Delete', confirmColor: AppTheme.errorRed);
    if (!ok) return;
    try {
      await _electionService.deleteElection(e.id);
      if (mounted) { ErrorHandler.showSuccessSnackBar(context, 'Election deleted!'); _load(); }
    } catch (err) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $err');
    }
  }
}

// ─── Stat model ───────────────────────────────────────────────────────────────

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

// ─── Election Card ────────────────────────────────────────────────────────────

class _ElectionCard extends StatefulWidget {
  final Election election;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _ElectionCard({
    required this.election,
    required this.onTap,
    required this.onActivate,
    required this.onClose,
    required this.onDelete,
  });

  @override
  State<_ElectionCard> createState() => _ElectionCardState();
}

class _ElectionCardState extends State<_ElectionCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Countdown for active elections (ends in) OR draft with future start (starts in)
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
      r = widget.election.endDate.difference(now);
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

  Color get _statusColor {
    switch (election.status) {
      case 'active': return AppTheme.successGreen;
      case 'closed': return Colors.grey;
      default: return AppTheme.accentOrange;
    }
  }

  IconData get _statusIcon {
    switch (election.status) {
      case 'active': return Icons.play_circle_rounded;
      case 'closed': return Icons.check_circle_rounded;
      default: return Icons.edit_rounded;
    }
  }

  String _fmt(DateTime d) {
    final local = d.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final turnout = election.voters.isNotEmpty
      ? (election.totalVotes / election.voters.length * 100).toStringAsFixed(0)
      : '0';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppTheme.softShadow],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Top accent bar ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Title row
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(election.statusDisplay.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor)),
                  ]),
                ),
              ]),

              if (election.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(election.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ],

              // Countdown chip
              if (election.isActive || (election.isDraft && election.startDate.isAfter(DateTime.now()))) ...[
                const SizedBox(height: 10),
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

              // Stats row
              Row(children: [
                _statChip(Icons.person_rounded, '${election.candidates.length}', 'Candidates',
                  const Color(0xFF4361EE)),
                const SizedBox(width: 8),
                _statChip(Icons.people_rounded, '${election.voters.length}', 'Voters',
                  const Color(0xFF7B2FBE)),
                const SizedBox(width: 8),
                _statChip(Icons.check_circle_rounded, '${election.totalVotes}', 'Votes',
                  AppTheme.successGreen),
              ]),

              const SizedBox(height: 12),

              // Date + turnout row
              Row(children: [
                Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text('${_fmt(election.startDate)} – ${_fmt(election.endDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const Spacer(),
                Icon(Icons.trending_up_rounded, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('$turnout% turnout',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),

              // Turnout progress bar
              if (election.voters.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: election.totalVotes / election.voters.length,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(_statusColor),
                  ),
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Action buttons
              Row(children: [
                if (election.isDraft)
                  _actionBtn(Icons.play_arrow_rounded, 'Activate', AppTheme.successGreen, widget.onActivate)
                else if (election.isActive)
                  _actionBtn(Icons.stop_rounded, 'Close', AppTheme.errorRed, widget.onClose),

                const Spacer(),

                _outlineBtn(Icons.visibility_rounded, 'View', widget.onTap),
                const SizedBox(width: 8),

                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey.shade400),
                  onSelected: (v) { if (v == 'delete') widget.onDelete(); },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Row(children: [
                      Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ])),
                  ],
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppTheme.primaryNavy),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: AppTheme.primaryNavy)),
        ]),
      ),
    );
  }
}
