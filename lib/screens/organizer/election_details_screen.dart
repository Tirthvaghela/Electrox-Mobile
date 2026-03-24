import 'package:flutter/material.dart';
import '../../models/election.dart';
import '../../config/theme.dart';
import '../../services/election_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/pdf_generator.dart';
import 'edit_election_screen.dart';

class ElectionDetailsScreen extends StatefulWidget {
  final Election election;

  const ElectionDetailsScreen({super.key, required this.election});

  @override
  State<ElectionDetailsScreen> createState() => _ElectionDetailsScreenState();
}

class _ElectionDetailsScreenState extends State<ElectionDetailsScreen>
    with SingleTickerProviderStateMixin {
  final ElectionService _electionService = ElectionService();
  late TabController _tabController;
  bool _isLoading = false;
  ElectionResults? _results;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.election.isActive || widget.election.isClosed) _loadResults();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    try {
      final data = await _electionService.getResults(
        widget.election.id, 'organizer', widget.election.organizerEmail);
      setState(() => _results = ElectionResults.fromJson(data));
    } catch (_) {}
  }

  Color get _statusColor {
    switch (widget.election.status) {
      case 'active': return AppTheme.successGreen;
      case 'draft':  return AppTheme.accentOrange;
      default:       return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverAppBar()],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildCandidatesTab(),
                  _buildVotersTab(),
                  _buildResultsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (_) => [
            _menuItem('edit', Icons.edit, 'Edit Election', null),
            if (widget.election.isActive || widget.election.isClosed) ...[
              _menuItem('export_results', Icons.download, 'Export Results', null),
              _menuItem('export_voters', Icons.people, 'Export Voters', null),
            ],
            if (widget.election.isActive)
              _menuItem('send_reminders', Icons.notifications, 'Send Reminders', null),
            _menuItem('delete', Icons.delete, 'Delete Election', AppTheme.errorRed),
          ],
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          widget.election.statusDisplay.toUpperCase(),
                          style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.election.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.election.organizerEmail,
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, Color? color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: color != null ? TextStyle(color: color) : null),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryNavy,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryNavy,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.info_outline, size: 18)),
          Tab(text: 'Candidates', icon: Icon(Icons.person_outline, size: 18)),
          Tab(text: 'Voters', icon: Icon(Icons.people_outline, size: 18)),
          Tab(text: 'Results', icon: Icon(Icons.bar_chart, size: 18)),
        ],
      ),
    );
  }

  // ── OVERVIEW TAB ──────────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    final e = widget.election;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats grid
          Row(children: [
            Expanded(child: _statCard('Candidates', '${e.candidates.length}', Icons.person, AppTheme.primaryNavy)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Voters', '${e.voters.length}', Icons.people, AppTheme.successGreen)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Votes Cast', '${e.totalVotes}', Icons.how_to_vote, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Turnout', '${e.turnoutPercentage.toStringAsFixed(1)}%', Icons.trending_up, AppTheme.accentOrange)),
          ]),
          const SizedBox(height: 20),

          // Turnout bar
          if (e.voters.isNotEmpty) ...[
            _sectionCard('Voter Turnout', Icons.show_chart, AppTheme.successGreen, [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${e.totalVotes} of ${e.voters.length} voted',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                Text('${e.turnoutPercentage.toStringAsFixed(1)}%',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryNavy, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: e.turnoutPercentage / 100,
                  minHeight: 8,
                  backgroundColor: AppTheme.backgroundGray,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.successGreen),
                ),
              ),
            ]),
            const SizedBox(height: 16),
          ],

          // Details card
          _sectionCard('Election Details', Icons.info_outline, AppTheme.primaryNavy, [
            _detailRow('Description', e.description),
            _detailRow('Start', _formatDate(e.startDate)),
            _detailRow('End', _formatDate(e.endDate)),
            _detailRow('Visibility', _visibilityText(e.resultVisibility)),
            _detailRow('Created', _formatDate(e.createdAt)),
            if (e.closedAt != null) _detailRow('Closed', _formatDate(e.closedAt!)),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _sectionCard(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTheme.titleMedium),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 90,
          child: Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
        ),
        Expanded(child: Text(value, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500))),
      ]),
    );
  }

  // ── CANDIDATES TAB ────────────────────────────────────────────────────────
  Widget _buildCandidatesTab() {
    final candidates = widget.election.candidates;
    if (candidates.isEmpty) return _emptyState(Icons.person_outline, 'No candidates', 'No candidates added yet');

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingScreen),
      itemCount: candidates.length,
      itemBuilder: (_, i) {
        final c = candidates[i];
        final votes = _getCandidateVotes(c.email);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppTheme.paddingCard),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: const [AppTheme.softShadow],
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryNavy,
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: AppTheme.titleMedium),
              Text(c.email, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
              if (c.bio != null && c.bio!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(c.bio!, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ])),
            if (_results != null)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$votes', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                Text('votes', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
              ]),
          ]),
        );
      },
    );
  }

  // ── VOTERS TAB ────────────────────────────────────────────────────────────
  Widget _buildVotersTab() {
    final e = widget.election;
    return Column(children: [
      // Summary bar
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: Row(children: [
          Expanded(child: _voterStat('${e.totalVotes}', 'Voted', AppTheme.successGreen)),
          Expanded(child: _voterStat('${e.remainingVoters}', 'Pending', AppTheme.accentOrange)),
          Expanded(child: _voterStat('${e.voters.length}', 'Total', AppTheme.primaryNavy)),
        ]),
      ),
      Expanded(
        child: e.voters.isEmpty
            ? _emptyState(Icons.people_outline, 'No voters', 'No voters registered yet')
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.paddingScreen),
                itemCount: e.voters.length,
                itemBuilder: (_, i) {
                  final v = e.voters[i];
                  final voted = v.hasVoted ?? false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      boxShadow: const [AppTheme.softShadow],
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: voted
                            ? AppTheme.successGreen.withOpacity(0.15)
                            : AppTheme.backgroundGray,
                        child: Icon(
                          voted ? Icons.check : Icons.person_outline,
                          color: voted ? AppTheme.successGreen : AppTheme.textHint,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.name, style: AppTheme.titleMedium),
                        Text(v.email, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: voted
                              ? AppTheme.successGreen.withOpacity(0.1)
                              : AppTheme.backgroundGray,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          voted ? 'Voted' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: voted ? AppTheme.successGreen : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _voterStat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
    ]);
  }

  // ── RESULTS TAB ───────────────────────────────────────────────────────────
  Widget _buildResultsTab() {
    if (_results == null) {
      return _emptyState(Icons.bar_chart, 'Results not available',
          'Results will appear once the election is active or closed');
    }

    final r = _results!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingScreen),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary
        Row(children: [
          Expanded(child: _statCard('Total Votes', '${r.totalVotes}', Icons.how_to_vote, AppTheme.primaryNavy)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Turnout', '${r.turnoutPercentage.toStringAsFixed(1)}%',
              Icons.trending_up, AppTheme.successGreen)),
        ]),
        const SizedBox(height: 16),

        // Winner
        if (r.winner != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingCard),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: const [AppTheme.softShadow],
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4), width: 1.5),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Winner', style: TextStyle(
                    color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.w700)),
                Text(r.winner!.name, style: AppTheme.titleLarge),
                Text(
                  '${r.winner!.votes} votes · ${r.winner!.getPercentage(r.totalVotes).toStringAsFixed(1)}%',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        Text('All Results', style: AppTheme.headlineMedium),
        const SizedBox(height: 12),

        ...r.results.asMap().entries.map((entry) {
          final i = entry.key;
          final res = entry.value;
          final pct = res.getPercentage(r.totalVotes);
          final rankColor = i == 0
              ? const Color(0xFFFFB300)
              : i == 1 ? const Color(0xFF9E9E9E) : i == 2 ? const Color(0xFF8D6E63) : AppTheme.textHint;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppTheme.paddingCard),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: const [AppTheme.softShadow],
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.15), shape: BoxShape.circle),
                  child: Center(
                    child: i < 3
                        ? Icon(i == 0 ? Icons.emoji_events : Icons.star, color: rankColor, size: 18)
                        : Text('${i + 1}', style: TextStyle(
                            color: rankColor, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(res.name, style: AppTheme.titleMedium),
                  Text(res.email, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${res.votes}', style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: rankColor)),
                  Text('${pct.toStringAsFixed(1)}%',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                ]),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: r.totalVotes > 0 ? pct / 100 : 0,
                  minHeight: 6,
                  backgroundColor: AppTheme.backgroundGray,
                  valueColor: AlwaysStoppedAnimation(i == 0 ? rankColor : AppTheme.primaryNavy.withOpacity(0.5)),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 44, color: AppTheme.primaryNavy),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(subtitle,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
      ]),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _visibilityText(String v) {
    switch (v) {
      case 'live':       return 'Live — visible during voting';
      case 'final_only': return 'Final only — visible after close';
      default:           return 'Hidden — organizers only';
    }
  }

  int _getCandidateVotes(String email) {
    if (_results == null) return 0;
    return _results!.results
        .firstWhere((r) => r.email == email,
            orElse: () => CandidateResult(name: '', email: '', votes: 0))
        .votes;
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'edit':           _editElection();   break;
      case 'export_results': _exportResults();  break;
      case 'export_voters':  _exportVoters();   break;
      case 'send_reminders': _sendReminders();  break;
      case 'delete':         _confirmDelete();  break;
    }
  }

  Future<void> _editElection() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditElectionScreen(election: widget.election)));
    if (result == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _exportResults() async {
    // Ensure we have results loaded
    ElectionResults? results = _results;
    if (results == null) {
      setState(() => _isLoading = true);
      try {
        final data = await _electionService.getResults(
            widget.election.id, 'organizer', widget.election.organizerEmail);
        results = ElectionResults.fromJson(data);
        setState(() => _results = results);
      } catch (e) {
        if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed to load results: $e');
        setState(() => _isLoading = false);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await PdfGenerator.exportElectionResults(
        election: widget.election,
        results: results!,
      );
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'PDF export failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportVoters() async {
    setState(() => _isLoading = true);
    try {
      await _electionService.exportVoters(widget.election.id);
      if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Voters exported!');
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Export failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReminders() async {
    final ok = await ErrorHandler.showConfirmationDialog(
        context, 'Send Reminders', 'Send reminder emails to voters who haven\'t voted yet?',
        confirmText: 'Send');
    if (!ok) return;
    setState(() => _isLoading = true);
    try {
      await _electionService.sendReminders(widget.election.id);
      if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Reminders sent!');
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await ErrorHandler.showConfirmationDialog(
        context, 'Delete Election',
        'Delete "${widget.election.title}"? This cannot be undone.',
        confirmText: 'Delete', confirmColor: Colors.red);
    if (!ok) return;
    setState(() => _isLoading = true);
    try {
      await _electionService.deleteElection(widget.election.id);
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Election deleted');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
