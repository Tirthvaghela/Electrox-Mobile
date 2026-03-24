import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../utils/error_handler.dart';
import '../../utils/pdf_generator.dart';

class ElectionResultsScreen extends StatefulWidget {
  final Election election;

  const ElectionResultsScreen({super.key, required this.election});

  @override
  State<ElectionResultsScreen> createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  final ElectionService _electionService = ElectionService();
  ElectionResults? _results;
  bool _isLoading = true;
  bool _isExporting = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadResults();
    // Live polling every 30s when election is active
    if (widget.election.isActive) {
      _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadResults());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final data = await _electionService.getResults(
        widget.election.id,
        'candidate',
        authProvider.userEmail!,
      );
      setState(() {
        _results = ElectionResults.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed to load results: $e');
    }
  }

  Future<void> _exportPdf() async {
    if (_results == null) return;
    setState(() => _isExporting = true);
    try {
      await PdfGenerator.exportElectionResults(
        election: widget.election,
        results: _results!,
      );
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'PDF export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        onRefresh: _loadResults,
        color: AppTheme.primaryNavy,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryNavy),
                ),
              )
            else if (_results == null)
              SliverFillRemaining(child: _buildEmptyState())
            else if (!_results!.visible)
              SliverFillRemaining(child: _buildHiddenState())
            else
              SliverToBoxAdapter(
                child: _buildContent(authProvider.userEmail!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isClosed = widget.election.isClosed;
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: const Color(0xFF4A148C),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isExporting)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          )
        else if (_results != null && _results!.visible && widget.election.isClosed)
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Export PDF',
            onPressed: _exportPdf,
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadResults,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0050), Color(0xFF4A148C)],
            ),
          ),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isClosed ? Icons.bar_chart : Icons.show_chart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isClosed ? 'Final Results' : 'Live Results',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.election.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String myEmail) {
    final results = _results!;
    final isWinner = results.winner?.email == myEmail;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Votes', '${results.totalVotes}',
                  Icons.how_to_vote, const Color(0xFF4A148C))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Turnout',
                  '${results.turnoutPercentage.toStringAsFixed(1)}%',
                  Icons.trending_up, AppTheme.successGreen)),
            ],
          ),
          const SizedBox(height: 16),

          // My performance card
          _buildMyPerformanceCard(myEmail, isWinner),
          const SizedBox(height: 20),

          // All results
          Text('All Candidates', style: AppTheme.headlineMedium),
          const SizedBox(height: 12),

          ...results.results.asMap().entries.map((entry) =>
              _buildResultCard(entry.key, entry.value, myEmail, results.totalVotes)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              Text(label,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyPerformanceCard(String myEmail, bool isWinner) {
    if (_results == null) return const SizedBox.shrink();

    final myResult = _results!.results.firstWhere(
      (r) => r.email == myEmail,
      orElse: () => CandidateResult(name: 'Unknown', email: myEmail, votes: 0),
    );
    final myPosition = _results!.results.indexWhere((r) => r.email == myEmail) + 1;
    final percentage = myResult.getPercentage(_results!.totalVotes);

    final cardColor = isWinner ? AppTheme.successGreen : const Color(0xFF4A148C);

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
        border: Border.all(color: cardColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isWinner ? Icons.emoji_events : Icons.person,
                  color: cardColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWinner ? 'Congratulations! 🎉' : 'Your Performance',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: cardColor),
                  ),
                  Text(
                    isWinner ? 'You won this election!' : 'Position #$myPosition',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMiniStat('${myResult.votes}', 'Votes', cardColor)),
              Expanded(child: _buildMiniStat('${percentage.toStringAsFixed(1)}%', 'Share', AppTheme.accentOrange)),
              Expanded(child: _buildMiniStat('#$myPosition', 'Rank',
                  myPosition == 1 ? AppTheme.successGreen : AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildResultCard(int index, CandidateResult result, String myEmail, int totalVotes) {
    final isMe = result.email == myEmail;
    final isWinner = index == 0;
    final percentage = result.getPercentage(totalVotes);

    final Color rankColor = index == 0
        ? const Color(0xFFFFB300)
        : index == 1
            ? const Color(0xFF9E9E9E)
            : index == 2
                ? const Color(0xFF8D6E63)
                : AppTheme.textHint;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
        border: isMe
            ? Border.all(color: const Color(0xFF4A148C).withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: index < 3
                      ? Icon(
                          index == 0 ? Icons.emoji_events : Icons.star,
                          color: rankColor,
                          size: 20,
                        )
                      : Text('${index + 1}',
                          style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              // Candidate info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(result.name,
                              style: AppTheme.titleMedium.copyWith(
                                color: isWinner
                                    ? const Color(0xFFFFB300)
                                    : AppTheme.textPrimary,
                              )),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A148C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('You',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                        if (isWinner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Winner',
                                style: TextStyle(
                                    color: Color(0xFFFFB300),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    Text(result.email,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Vote count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${result.votes}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isWinner ? const Color(0xFFFFB300) : AppTheme.primaryNavy)),
                  Text('${percentage.toStringAsFixed(1)}%',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalVotes > 0 ? percentage / 100 : 0,
              minHeight: 6,
              backgroundColor: AppTheme.backgroundGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinner
                    ? const Color(0xFFFFB300)
                    : isMe
                        ? const Color(0xFF4A148C)
                        : AppTheme.primaryNavy.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart, size: 48, color: AppTheme.primaryNavy),
          ),
          const SizedBox(height: 16),
          const Text('Results not available', style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Results will appear once the election is active or closed.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, size: 48, color: AppTheme.accentOrange),
          ),
          const SizedBox(height: 16),
          const Text('Results Hidden', style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'The organizer has set results to be hidden until the election closes.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
