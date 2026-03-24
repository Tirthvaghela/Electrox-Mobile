import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/election.dart';
import '../../services/election_service.dart';
import '../../utils/error_handler.dart';

class EditElectionScreen extends StatefulWidget {
  final Election election;
  const EditElectionScreen({super.key, required this.election});

  @override
  State<EditElectionScreen> createState() => _EditElectionScreenState();
}

class _EditElectionScreenState extends State<EditElectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ElectionService _service = ElectionService();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _visibility;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.election;
    _titleCtrl = TextEditingController(text: e.title);
    _descCtrl = TextEditingController(text: e.description);
    _startDate = e.startDate;
    _endDate = e.endDate;
    _visibility = e.resultVisibility;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
        if (_endDate.isBefore(_startDate)) _endDate = _startDate.add(const Duration(days: 1));
      } else {
        if (dt.isAfter(_startDate)) _endDate = dt;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await _service.updateElection(widget.election.id, {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'start_date': _startDate.toIso8601String(),
        'end_date': _endDate.toIso8601String(),
        'result_visibility': _visibility,
      });
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Election updated!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showErrorSnackBar(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(children: [
                _card([
                  _label('Election Title'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: _deco('e.g. Student of the Year 2026', Icons.title_rounded),
                    validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15),
                    decoration: _deco('Brief description', Icons.description_rounded),
                    validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
                  ),
                ]),
                const SizedBox(height: 14),
                _card([
                  _sectionLabel('Schedule', Icons.schedule_rounded, const Color(0xFF7B2FBE)),
                  Row(children: [
                    Expanded(child: _dateTile('Start Date', _startDate, () => _pickDate(true))),
                    const SizedBox(width: 10),
                    Expanded(child: _dateTile('End Date', _endDate, () => _pickDate(false))),
                  ]),
                ]),
                const SizedBox(height: 14),
                _card([
                  _sectionLabel('Result Visibility', Icons.visibility_rounded, AppTheme.accentOrange),
                  ...[
                    ('hidden', 'Hidden', 'Only organizers can see results', Icons.lock_rounded),
                    ('live', 'Live', 'Results visible during voting', Icons.live_tv_rounded),
                    ('final_only', 'Final Only', 'Results visible after election closes', Icons.lock_open_rounded),
                  ].map((opt) => _visibilityTile(opt.$1, opt.$2, opt.$3, opt.$4)),
                ]),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ),
        _buildBottomBar(),
      ]),
    );
  }

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
                  color: AppTheme.accentOrange, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Edit Election',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Update election details',
                  style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSaving
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [AppTheme.softShadow],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));

  Widget _sectionLabel(String text, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
    prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
    filled: true,
    fillColor: AppTheme.backgroundGray,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorRed)),
  );

  Widget _dateTile(String label, DateTime dt, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.backgroundGray, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(
              fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryNavy),
            const SizedBox(width: 6),
            Expanded(child: Text(_fmtDate(dt),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
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
              color: selected ? AppTheme.accentOrange : Colors.transparent, width: 1.5),
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
          if (selected) const Icon(Icons.check_circle_rounded, color: AppTheme.accentOrange, size: 20),
        ]),
      ),
    );
  }
}
