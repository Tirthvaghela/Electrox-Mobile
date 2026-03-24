import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../utils/error_handler.dart';

class VotingScreen extends StatefulWidget {
  final Election election;

  const VotingScreen({super.key, required this.election});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final ElectionService _electionService = ElectionService();
  String? _selectedCandidateEmail;
  bool _isSubmitting = false;
  bool _voteSubmitted = false;
  String _submittedCandidateName = '';

  @override
  Widget build(BuildContext context) {
    if (_voteSubmitted) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isSubmitting
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTheme.primaryNavy),
                          SizedBox(height: 16),
                          Text('Submitting your vote...', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  )
                : _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: _isSubmitting || _voteSubmitted ? null : _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.how_to_vote, color: AppTheme.accentOrange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.election.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          widget.election.title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildNoticeBar(),
          const SizedBox(height: 20),
          Text('Candidates (${widget.election.candidates.length})',
              style: AppTheme.headlineMedium),
          const SizedBox(height: 12),
          ...widget.election.candidates.asMap().entries.map((e) =>
              _buildCandidateCard(e.value)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingCard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.election.description,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.schedule, 'Ends ${_formatDate(widget.election.endDate)}',
                  AppTheme.accentOrange),
              const SizedBox(width: 8),
              _infoChip(Icons.people, '${widget.election.candidates.length} candidates',
                  AppTheme.primaryNavy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.bodySmall.copyWith(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNoticeBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppTheme.accentOrange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your vote is anonymous and cannot be changed once submitted.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Candidate candidate) {
    final isSelected = _selectedCandidateEmail == candidate.email;
    return GestureDetector(
      onTap: () => setState(() => _selectedCandidateEmail = candidate.email),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryNavy.withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Accent bar on top when selected
            if (isSelected)
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusCard),
                    topRight: Radius.circular(AppTheme.radiusCard),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingCard),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isSelected
                        ? AppTheme.primaryNavy
                        : AppTheme.primaryNavy.withOpacity(0.12),
                    child: candidate.photo != null
                        ? ClipOval(
                            child: Image.network(
                              candidate.photo!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarInitial(candidate, isSelected),
                            ),
                          )
                        : _avatarInitial(candidate, isSelected),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.name,
                            style: AppTheme.titleMedium.copyWith(
                              color: isSelected ? AppTheme.primaryNavy : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 2),
                        Text(candidate.email,
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(candidate.bio!,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Radio indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryNavy : AppTheme.textHint,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarInitial(Candidate candidate, bool isSelected) {
    return Text(
      candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : 'C',
      style: TextStyle(
        color: isSelected ? Colors.white : AppTheme.primaryNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _selectedCandidateEmail != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: canSubmit ? _showConfirmationSheet : null,
          icon: const Icon(Icons.how_to_vote, size: 20),
          label: const Text('Submit Vote', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: canSubmit ? AppTheme.primaryNavy : AppTheme.textHint,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showConfirmationSheet() {
    final candidate = widget.election.candidates.firstWhere(
      (c) => c.email == _selectedCandidateEmail,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.how_to_vote, color: AppTheme.primaryNavy, size: 40),
            const SizedBox(height: 12),
            const Text('Confirm Your Vote', style: AppTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('You are voting for:', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryNavy,
                    child: Text(
                      candidate.name.isNotEmpty ? candidate.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.name, style: AppTheme.titleMedium),
                        Text(candidate.email,
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Your vote is final.',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primaryNavy),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitVote();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                      elevation: 0,
                    ),
                    child: const Text('Confirm Vote',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateEmail == null) return;
    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _electionService.castVote(
        widget.election.id,
        authProvider.userEmail!,
        _selectedCandidateEmail!,
      );

      final candidate = widget.election.candidates.firstWhere(
        (c) => c.email == _selectedCandidateEmail,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _voteSubmitted = true;
          _submittedCandidateName = candidate.name;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ErrorHandler.showErrorSnackBar(context, 'Failed to submit vote: $e');
      }
    }
  }

  Widget _buildSuccessScreen() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final timestamp = '${months[now.month-1]} ${now.day}, ${now.year}  '
        '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 16),
            // Success icon
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Vote Submitted!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
            const SizedBox(height: 6),
            const Text('Your vote has been recorded anonymously.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
            const SizedBox(height: 28),

            // Receipt card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [AppTheme.softShadow],
              ),
              child: Column(children: [
                // Receipt header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('Vote Receipt',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('CONFIRMED',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),

                // Dashed divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: List.generate(30, (i) => Expanded(
                    child: Container(
                      height: 1,
                      color: i % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                    ),
                  ))),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    _receiptRow('Election', widget.election.title),
                    const SizedBox(height: 14),
                    _receiptRow('Voted For', _submittedCandidateName),
                    const SizedBox(height: 14),
                    _receiptRow('Timestamp', timestamp),
                    const SizedBox(height: 14),
                    _receiptRow('Election ID', '#${widget.election.id.substring(0, 8).toUpperCase()}'),
                    const SizedBox(height: 14),
                    _receiptRow('Status', 'Recorded'),
                  ]),
                ),

                // Bottom dashed
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: List.generate(30, (i) => Expanded(
                    child: Container(
                      height: 1,
                      color: i % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                    ),
                  ))),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    const Text('Secured & Anonymous',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text('Back to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy),
            textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
