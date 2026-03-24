import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/election_service.dart';
import '../../services/template_service.dart';
import '../../utils/error_handler.dart';

class CreateElectionScreen extends StatefulWidget {
  const CreateElectionScreen({super.key});

  @override
  State<CreateElectionScreen> createState() => _CreateElectionScreenState();
}

class _CreateElectionScreenState extends State<CreateElectionScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Step 1 – Details
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate   = DateTime.now().add(const Duration(days: 7));
  String _visibility  = 'hidden';

  // CSV / participants
  String? _csvFileName;
  List<Map<String, String>> _participants = [];

  // Step 2 – Candidates
  final List<Map<String, String>> _candidates = [];
  final _cNameCtrl = TextEditingController();
  final _cEmailCtrl = TextEditingController();
  final _cBioCtrl  = TextEditingController();
  String? _selectedFromList;

  final ElectionService _electionService = ElectionService();
  final TemplateService _templateService = TemplateService();

  static const _steps = ['Details', 'Candidates', 'Review'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _cNameCtrl.dispose(); _cEmailCtrl.dispose(); _cBioCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}  '
    '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  InputDecoration _dec(String label, IconData icon, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: AppTheme.backgroundGray,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.errorRed)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
  );

  Widget _sectionLabel(String text, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Column(children: [
        _buildHeader(),
        _buildStepper(),
        Expanded(
          child: _isLoading
            ? const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating election…', style: TextStyle(color: AppTheme.textSecondary)),
                ]))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Form(key: _formKey, child: _buildStep()),
              ),
        ),
        _buildNavBar(),
      ]),
    );
  }

  // ── header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2E), AppTheme.primaryNavy],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Election',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Set up your election in 3 steps',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
            const Spacer(),
            IconButton(
              onPressed: _loadTemplate,
              tooltip: 'Templates',
              icon: const Icon(Icons.folder_open_rounded, color: AppTheme.accentOrange, size: 24),
            ),
          ]),
        ),
      ),
    );
  }

  // ── stepper ───────────────────────────────────────────────────────────────────

  Widget _buildStepper() {
    return Container(
      color: AppTheme.primaryNavy,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector
          final done = _step > i ~/ 2;
          return Expanded(child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: done ? AppTheme.accentOrange : Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ));
        }
        final idx = i ~/ 2;
        final active = _step == idx;
        final done   = _step > idx;
        return Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppTheme.accentOrange
                   : active ? Colors.white
                   : Colors.white24,
            ),
            child: Center(child: done
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : Text('${idx + 1}', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: active ? AppTheme.primaryNavy : Colors.white54))),
          ),
          const SizedBox(height: 4),
          Text(_steps[idx], style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.white54)),
        ]);
      })),
    );
  }

  // ── step router ───────────────────────────────────────────────────────────────

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildDetailsStep();
      case 1: return _buildCandidatesStep();
      case 2: return _buildReviewStep();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Details ───────────────────────────────────────────────────────────

  Widget _buildDetailsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      _card(children: [
        _sectionLabel('Election Info', Icons.info_rounded, const Color(0xFF4361EE)),
        TextFormField(
          controller: _titleCtrl,
          decoration: _dec('Election Title', Icons.title_rounded, hint: 'e.g. Student of the Year 2026'),
          validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: _dec('Description', Icons.description_rounded, hint: 'Brief description of this election'),
          validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
        ),
      ]),

      const SizedBox(height: 14),

      _card(children: [
        _sectionLabel('Schedule', Icons.schedule_rounded, const Color(0xFF7B2FBE)),
        Row(children: [
          Expanded(child: _dateTile('Start Date', _startDate, () => _pickDate(true))),
          const SizedBox(width: 10),
          Expanded(child: _dateTile('End Date', _endDate, () => _pickDate(false))),
        ]),
      ]),

      const SizedBox(height: 14),

      _card(children: [
        _sectionLabel('Result Visibility', Icons.visibility_rounded, AppTheme.accentOrange),
        DropdownButtonFormField<String>(
          value: _visibility,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.visibility_rounded, size: 20),
            filled: true,
            fillColor: AppTheme.backgroundGray,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          items: const [
            DropdownMenuItem(value: 'hidden',     child: Text('Hidden — Organizers only')),
            DropdownMenuItem(value: 'live',       child: Text('Live — Visible during voting')),
            DropdownMenuItem(value: 'final_only', child: Text('Final Only — After election closes')),
          ],
          onChanged: (v) => setState(() => _visibility = v!),
        ),
      ]),

      const SizedBox(height: 14),

      _card(children: [
        _sectionLabel('Participants CSV', Icons.upload_file_rounded, AppTheme.successGreen),
        GestureDetector(
          onTap: _uploadCSV,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _participants.isEmpty
                ? AppTheme.successGreen.withOpacity(0.05)
                : AppTheme.successGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _participants.isEmpty
                  ? Colors.grey.shade300
                  : AppTheme.successGreen.withOpacity(0.4),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(children: [
              Icon(
                _participants.isEmpty ? Icons.cloud_upload_rounded : Icons.check_circle_rounded,
                size: 40,
                color: _participants.isEmpty ? Colors.grey.shade400 : AppTheme.successGreen,
              ),
              const SizedBox(height: 10),
              Text(
                _csvFileName ?? 'Tap to upload CSV file',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: _participants.isEmpty ? Colors.grey.shade600 : AppTheme.primaryNavy),
              ),
              const SizedBox(height: 4),
              Text(
                _participants.isEmpty
                  ? 'Format: name, email (one per row)'
                  : '${_participants.length} participants loaded',
                style: TextStyle(
                  fontSize: 12,
                  color: _participants.isEmpty ? Colors.grey.shade500 : AppTheme.successGreen),
              ),
            ]),
          ),
        ),
        if (_participants.isNotEmpty) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _uploadCSV,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Text('Change file'),
          ),
        ],
      ]),

      const SizedBox(height: 80),
    ]);
  }

  Widget _dateTile(String label, DateTime dt, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryNavy),
            const SizedBox(width: 6),
            Expanded(child: Text(_fmtDate(dt),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy))),
          ]),
        ]),
      ),
    );
  }

  Widget _visibilityTile(String value, String title, String subtitle, IconData icon) {
    final selected = _visibility == value;
    return GestureDetector(
      onTap: () => setState(() => _visibility = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentOrange.withOpacity(0.08) : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.accentOrange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? AppTheme.accentOrange.withOpacity(0.15) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: selected ? AppTheme.accentOrange : Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: selected ? AppTheme.primaryNavy : AppTheme.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: AppTheme.accentOrange, size: 20),
        ]),
      ),
    );
  }

  // ── Step 2: Candidates ────────────────────────────────────────────────────────

  Widget _buildCandidatesStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Add candidate form
      _card(children: [
        _sectionLabel('Add Candidate', Icons.person_add_rounded, const Color(0xFF4361EE)),

        if (_participants.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            value: _selectedFromList,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.backgroundGray,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            hint: const Text('Select from CSV list', overflow: TextOverflow.ellipsis),
            items: [
              const DropdownMenuItem(value: null, child: Text('— Manual entry —')),
              ..._participants.map((p) => DropdownMenuItem(
                value: p['email'],
                child: Text('${p['name']}  (${p['email']})',
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              )),
            ],
            onChanged: (v) {
              setState(() {
                _selectedFromList = v;
                if (v != null) {
                  final p = _participants.firstWhere((x) => x['email'] == v);
                  _cNameCtrl.text  = p['name'] ?? '';
                  _cEmailCtrl.text = p['email'] ?? '';
                } else {
                  _cNameCtrl.clear(); _cEmailCtrl.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('or enter manually', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
            Expanded(child: Divider()),
          ]),
          const SizedBox(height: 12),
        ],

        Row(children: [
          Expanded(child: TextFormField(
            controller: _cNameCtrl,
            decoration: _dec('Full Name', Icons.person_rounded),
          )),
          const SizedBox(width: 10),
          Expanded(child: TextFormField(
            controller: _cEmailCtrl,
            decoration: _dec('Email', Icons.email_rounded),
            keyboardType: TextInputType.emailAddress,
            readOnly: _selectedFromList != null,
          )),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cBioCtrl,
          maxLines: 2,
          decoration: _dec('Bio / Description', Icons.notes_rounded,
            hint: 'Brief description of the candidate'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: _addCandidate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Candidate', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),

      const SizedBox(height: 14),

      // Candidates list
      if (_candidates.isNotEmpty)
        _card(children: [
          _sectionLabel('Added Candidates (${_candidates.length})',
            Icons.people_rounded, const Color(0xFF7B2FBE)),
          ..._candidates.asMap().entries.map((e) => _candidateTile(e.key, e.value)),
        ]),

      const SizedBox(height: 80),
    ]);
  }

  Widget _candidateTile(int idx, Map<String, String> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF4361EE).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text('${idx + 1}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
              color: Color(0xFF4361EE)))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: AppTheme.primaryNavy)),
          Text(c['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          if ((c['bio'] ?? '').isNotEmpty)
            Text(c['bio']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        IconButton(
          onPressed: () => setState(() => _candidates.removeAt(idx)),
          icon: const Icon(Icons.delete_rounded, size: 18, color: AppTheme.errorRed),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
      ]),
    );
  }

  // ── Step 3: Review ────────────────────────────────────────────────────────────

  Widget _buildReviewStep() {
    final voterCount = _participants.where(
      (p) => !_candidates.any((c) => c['email'] == p['email'])).length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      _card(children: [
        _sectionLabel('Election Details', Icons.info_rounded, const Color(0xFF4361EE)),
        _reviewRow('Title', _titleCtrl.text),
        _reviewRow('Description', _descCtrl.text),
        _reviewRow('Start', _fmtDate(_startDate)),
        _reviewRow('End', _fmtDate(_endDate)),
        _reviewRow('Visibility', {
          'hidden': 'Hidden', 'live': 'Live', 'final_only': 'Final Only'
        }[_visibility] ?? _visibility),
      ]),

      const SizedBox(height: 14),

      _card(children: [
        _sectionLabel('Participants', Icons.people_rounded, const Color(0xFF7B2FBE)),
        Row(children: [
          _summaryChip(Icons.person_rounded, '${_candidates.length}', 'Candidates', const Color(0xFF4361EE)),
          const SizedBox(width: 10),
          _summaryChip(Icons.how_to_vote_rounded, '$voterCount', 'Voters', AppTheme.successGreen),
          const SizedBox(width: 10),
          _summaryChip(Icons.people_rounded, '${_participants.length}', 'Total', const Color(0xFF7B2FBE)),
        ]),
      ]),

      const SizedBox(height: 14),

      _card(children: [
        _sectionLabel('Candidates (${_candidates.length} — min 2)', Icons.person_rounded, const Color(0xFF4361EE)),
        ..._candidates.asMap().entries.map((e) => _candidateTile(e.key, e.value)),
      ]),

      const SizedBox(height: 14),

      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF4361EE).withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4361EE).withOpacity(0.2)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF4361EE)),
          SizedBox(width: 10),
          Expanded(child: Text(
            'After creation, activate the election when you\'re ready to start voting.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4361EE)),
          )),
        ]),
      ),

      const SizedBox(height: 12),

      // Save as template
      OutlinedButton.icon(
        onPressed: _saveAsTemplate,
        icon: const Icon(Icons.save_outlined, size: 18, color: AppTheme.primaryNavy),
        label: const Text('Save as Template',
            style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppTheme.primaryNavy),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 0),
        ),
      ),

      const SizedBox(height: 80),
    ]);
  }

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary))),
      Expanded(child: Text(value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppTheme.primaryNavy))),
    ]),
  );

  Widget _summaryChip(IconData icon, String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ]),
    ),
  );

  // ── Nav bar ───────────────────────────────────────────────────────────────────

  Widget _buildNavBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(children: [
        if (_step > 0) ...[
          OutlinedButton(
            onPressed: () => setState(() => _step--),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(children: [
              Icon(Icons.arrow_back_rounded, size: 18, color: AppTheme.textSecondary),
              SizedBox(width: 6),
              Text('Back', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _step == 2 ? _createElection : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step == 2 ? AppTheme.successGreen : AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_step == 2) const Icon(Icons.rocket_launch_rounded, size: 18),
                if (_step != 2) Text(
                  _step == 0 ? 'Next: Add Candidates' : 'Next: Review',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (_step == 2) const SizedBox(width: 8),
                if (_step == 2) const Text('Create Election',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (_step != 2) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── card helper ───────────────────────────────────────────────────────────────

  Widget _card({required List<Widget> children}) => Container(
    margin: const EdgeInsets.only(bottom: 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [AppTheme.softShadow],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  // ── logic ─────────────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      if (_participants.isEmpty) {
        ErrorHandler.showErrorSnackBar(context, 'Please upload a CSV file first');
        return;
      }
    } else if (_step == 1) {
      if (_candidates.length < 2) {
        ErrorHandler.showErrorSnackBar(context, 'Add at least 2 candidates');
        return;
      }
    }
    setState(() => _step++);
  }

  void _addCandidate() {
    final name  = _cNameCtrl.text.trim();
    final email = _cEmailCtrl.text.trim();
    final bio   = _cBioCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || bio.isEmpty) {
      ErrorHandler.showErrorSnackBar(context, 'Fill in name, email and bio');
      return;
    }
    if (_candidates.any((c) => c['email'] == email)) {
      ErrorHandler.showErrorSnackBar(context, 'Candidate already added');
      return;
    }
    setState(() {
      _candidates.add({'name': name, 'email': email, 'bio': bio});
      _cNameCtrl.clear(); _cEmailCtrl.clear(); _cBioCtrl.clear();
      _selectedFromList = null;
    });
    ErrorHandler.showSuccessSnackBar(context, 'Candidate added!');
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = dt;
        // Push end date forward if it's no longer after start
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(const Duration(hours: 1));
        }
      } else {
        if (dt.isAfter(_startDate)) {
          _endDate = dt;
        } else {
          // Show error — end must be after start
          ErrorHandler.showErrorSnackBar(context, 'End date must be after start date');
        }
      }
    });
  }

  Future<void> _uploadCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['csv'], withData: true);
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      final csv = String.fromCharCodes(bytes);
      final parsed = _parseCSV(csv);
      setState(() {
        _csvFileName = result.files.first.name;
        _participants = parsed;
        _candidates.clear();
        _selectedFromList = null;
      });
      if (mounted) ErrorHandler.showSuccessSnackBar(
        context, '${parsed.length} participants loaded!');
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'CSV upload failed: $e');
    }
  }

  List<Map<String, String>> _parseCSV(String csv) {
    final lines = csv.split('\n');
    final result = <Map<String, String>>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 2) {
        result.add({
          'name':  parts[0].trim().replaceAll('"', ''),
          'email': parts[1].trim().replaceAll('"', ''),
        });
      }
    }
    return result;
  }

  Future<void> _loadTemplate() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final templates = await _templateService.getMyTemplates(auth.userEmail!);
      if (!mounted) return;
      if (templates.isEmpty) {
        ErrorHandler.showErrorSnackBar(context, 'No saved templates yet');
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Load Template', style: AppTheme.headlineMedium),
            const SizedBox(height: 16),
            ...templates.map((t) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.folder_rounded, color: AppTheme.accentOrange, size: 20),
              ),
              title: Text(t['name'] ?? '', style: AppTheme.titleMedium),
              subtitle: Text(t['description'] ?? '',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final data = await _templateService.useTemplate(t['_id']);
                  final td = data['template_data'] as Map<String, dynamic>? ?? {};
                  setState(() {
                    if (td['title'] != null) _titleCtrl.text = td['title'];
                    if (td['description'] != null) _descCtrl.text = td['description'];
                    if (td['result_visibility'] != null) _visibility = td['result_visibility'];
                  });
                  if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Template loaded!');
                } catch (e) {
                  if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
                }
              },
            )),
          ]),
        ),
      );
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed to load templates: $e');
    }
  }

  Future<void> _saveAsTemplate() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: _titleCtrl.text);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusModal)),
        title: const Text('Save as Template', style: AppTheme.titleLarge),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Template name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _templateService.createTemplate(
        name: nameCtrl.text.trim().isEmpty ? _titleCtrl.text : nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        organizerEmail: auth.userEmail!,
        organizationId: auth.organizationId ?? '',
        templateData: {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'result_visibility': _visibility,
        },
      );
      if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Template saved!');
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
    }
  }

  Future<void> _createElection() async {
    if (_candidates.length < 2) {
      ErrorHandler.showErrorSnackBar(context, 'Add at least 2 candidates');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await _electionService.createElection({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'organizer_email': auth.userEmail,
        'start_date': _startDate.toUtc().toIso8601String(),
        'end_date': _endDate.toUtc().toIso8601String(),
        'result_visibility': _visibility,
        'candidates': _candidates,
        'voters': _participants.where(
          (p) => !_candidates.any((c) => c['email'] == p['email'])).toList(),
      });
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Election created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
