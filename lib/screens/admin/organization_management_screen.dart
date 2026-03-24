import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/organization_service.dart';
import '../../services/admin_service.dart';
import '../../services/election_service.dart';
import '../../models/election.dart';
import '../../config/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../screens/organizer/election_details_screen.dart';

class OrganizationManagementScreen extends StatefulWidget {
  const OrganizationManagementScreen({super.key});

  @override
  State<OrganizationManagementScreen> createState() => _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState extends State<OrganizationManagementScreen> {
  final OrganizationService _orgService = OrganizationService();
  final AdminService _adminService = AdminService();
  List<dynamic> _organizations = [];
  bool _isLoading = true;
  String? _error;
  static const _pageSize = 15;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final orgs = await _orgService.getAllOrganizations();
      setState(() { _organizations = orgs; _isLoading = false; _visibleCount = _pageSize; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _loadOrganizations,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else if (_organizations.isEmpty)
              SliverFillRemaining(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.paddingScreen),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final visible = _organizations.take(_visibleCount).toList();
                      if (i < visible.length) {
                        return _OrgCard(
                          org: visible[i],
                          onEdit: () => _showEditDialog(visible[i]),
                          onDelete: () => _confirmDelete(visible[i]),
                          onSetupLink: () => _showSetupLinkDialog(visible[i]),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _visibleCount += _pageSize),
                            icon: const Icon(Icons.expand_more),
                            label: Text('Load more (${_organizations.length - _visibleCount} remaining)'),
                          ),
                        ),
                      );
                    },
                    childCount: _visibleCount < _organizations.length
                        ? _visibleCount + 1
                        : _organizations.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Org', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadOrganizations,
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.business_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Organizations',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          Text('${_organizations.length} total',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        ],
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

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text('Error: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadOrganizations, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No organizations yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Tap + to create your first organization', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateOrgSheet(
        orgService: _orgService,
        onCreated: (res, email, name) {
          if (res['email_sent'] == false) {
            _showManualSetupDialog(email, name, res['invitation_token'] ?? '');
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['email_sent'] == true
              ? 'Organization created! Invitation sent.'
              : 'Organization created. Email failed — use manual link.'),
            backgroundColor: res['email_sent'] == true ? Colors.green : Colors.orange,
          ));
          _loadOrganizations();
        },
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> org) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditOrgSheet(
        org: org,
        orgService: _orgService,
        onUpdated: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Organization updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ));
          _loadOrganizations();
        },
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> org) {
    final stats = org['stats'] ?? {};
    final users = stats['users'] ?? 0;
    final elections = stats['elections'] ?? 0;
    final orgName = org['name'] ?? 'this organization';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('Delete Organization',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to permanently delete "$orgName".',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (users > 0 || elections > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('This will also delete:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.errorRed)),
                  const SizedBox(height: 6),
                  if (users > 0)
                    _deleteWarningRow(Icons.people_rounded, '$users users (organizers, candidates, voters)'),
                  if (elections > 0)
                    _deleteWarningRow(Icons.how_to_vote_rounded, '$elections elections & all votes'),
                ]),
              ),
              const SizedBox(height: 10),
            ],
            const Text('This action cannot be undone.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final result = await _adminService.deleteOrganization(org['_id']);
                if (mounted) {
                  final deletedUsers = result['deleted_users'] ?? 0;
                  final deletedElections = result['deleted_elections'] ?? 0;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Deleted "$orgName" — $deletedUsers users, $deletedElections elections removed.'),
                    backgroundColor: AppTheme.successGreen,
                    duration: const Duration(seconds: 4),
                  ));
                  _loadOrganizations();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: AppTheme.errorRed,
                  ));
                }
              }
            },
            child: const Text('Delete Everything', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _deleteWarningRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppTheme.errorRed),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.errorRed))),
      ]),
    );
  }

  void _showSetupLinkDialog(Map<String, dynamic> org) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setup Link'),
        content: Text('Resend setup link for ${org['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature: resend setup email')));
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showManualSetupDialog(String email, String name, String token) {
    final serverHost = dotenv.env['SERVER_HOST'] ?? 'http://localhost:5000';
    final link = '$serverHost/api/auth/setup-account?token=$token';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manual Setup Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email failed for $email. Share this link manually:'),
            const SizedBox(height: 12),
            SelectableText(link, style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }
}

// ─── Edit Org Bottom Sheet ────────────────────────────────────────────────────

class _EditOrgSheet extends StatefulWidget {
  final Map<String, dynamic> org;
  final OrganizationService orgService;
  final VoidCallback onUpdated;

  const _EditOrgSheet({
    required this.org,
    required this.orgService,
    required this.onUpdated,
  });

  @override
  State<_EditOrgSheet> createState() => _EditOrgSheetState();
}

class _EditOrgSheetState extends State<_EditOrgSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _typeCtrl;
  bool _submitting = false;

  static const _orgTypes = [
    'University', 'College', 'Company', 'Government', 'NGO',
    'School', 'Association', 'Club', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.org['name'] ?? '');
    _typeCtrl = TextEditingController(text: widget.org['type'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.orgService.updateOrganization(widget.org['_id'], {
        'name': _nameCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final currentType = _typeCtrl.text;
    final validType = _orgTypes.contains(currentType) ? currentType : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded, color: AppTheme.accentOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Edit Organization',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                  Text(widget.org['name'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis),
                ]),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
              ),
            ]),

            const SizedBox(height: 24),

            // Current info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.1)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4361EE).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business_rounded, color: Color(0xFF4361EE), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.org['name'] ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                  Text('${widget.org['type'] ?? ''} · ${(widget.org['status'] ?? 'pending').toUpperCase()}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ])),
              ]),
            ),

            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Organization Info', Icons.business_rounded, const Color(0xFF4361EE)),
                const SizedBox(height: 12),

                // Name field
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDec(null, Icons.business_outlined,
                      hint: 'e.g. Gujarat University'),
                  validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),

                // Type dropdown
                DropdownButtonFormField<String>(
                  value: validType,
                  decoration: _inputDec(null, Icons.category_outlined),
                  hint: const Text('Select type'),
                  isExpanded: true,
                  items: _orgTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _typeCtrl.text = v ?? ''),
                  validator: (_) => _typeCtrl.text.isEmpty ? 'Type is required' : null,
                ),

                const SizedBox(height: 28),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Save Changes',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  InputDecoration _inputDec(String? label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: AppTheme.backgroundGray,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorRed)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
    );
  }
}

// ─── Create Org Bottom Sheet ──────────────────────────────────────────────────

class _CreateOrgSheet extends StatefulWidget {
  final OrganizationService orgService;
  final void Function(Map<String, dynamic> res, String email, String name) onCreated;

  const _CreateOrgSheet({required this.orgService, required this.onCreated});

  @override
  State<_CreateOrgSheet> createState() => _CreateOrgSheetState();
}

class _CreateOrgSheetState extends State<_CreateOrgSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  static const _orgTypes = [
    'University', 'College', 'Company', 'Government', 'NGO',
    'School', 'Association', 'Club', 'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _typeCtrl.dispose();
    _orgNameCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final res = await widget.orgService.createOrganization({
        'name': _nameCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
        'organizer_name': _orgNameCtrl.text.trim(),
        'organizer_email': _emailCtrl.text.trim(),
        'created_by': 'admin@electrox.com',
      });
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated(res, _emailCtrl.text.trim(), _orgNameCtrl.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business_rounded, color: AppTheme.accentOrange, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('New Organization',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
              Text('Fill in the details below',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
            ),
          ]),

          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Organization Info ──
              _sectionLabel('Organization Info', Icons.business_rounded, const Color(0xFF4361EE)),
              const SizedBox(height: 12),

              _field(
                controller: _nameCtrl,
                label: 'Organization Name',
                hint: 'e.g. Gujarat University',
                icon: Icons.business_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              // Type dropdown styled as a text field
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('', Icons.category_outlined),
                hint: const Text('Select type'),
                items: _orgTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => _typeCtrl.text = v ?? '',
                validator: (_) => _typeCtrl.text.isEmpty ? 'Type is required' : null,
              ),

              const SizedBox(height: 24),

              // ── Organizer Info ──
              _sectionLabel('Organizer Details', Icons.person_rounded, const Color(0xFF7B2FBE)),
              const SizedBox(height: 12),

              _field(
                controller: _orgNameCtrl,
                label: 'Full Name',
                hint: 'e.g. Tirth Vaghela',
                icon: Icons.person_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              _field(
                controller: _emailCtrl,
                label: 'Email Address',
                hint: 'organizer@example.com',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.accentOrange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'A setup invitation will be emailed to the organizer.',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                  )),
                ]),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _submitting
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_business_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Create Organization',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ]),
          ),
        ],
      ),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: AppTheme.backgroundGray,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorRed)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
      validator: validator,
    );
  }
}

// ─── Org Card Widget ──────────────────────────────────────────────────────────

class _OrgCard extends StatefulWidget {
  final Map<String, dynamic> org;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetupLink;

  const _OrgCard({
    required this.org,
    required this.onEdit,
    required this.onDelete,
    required this.onSetupLink,
  });

  @override
  State<_OrgCard> createState() => _OrgCardState();
}

class _OrgCardState extends State<_OrgCard> {
  final ElectionService _electionService = ElectionService();
  bool _expanded = false;
  bool _loadingElections = false;
  List<dynamic> _elections = [];

  Future<void> _loadElections() async {
    if (_elections.isNotEmpty) return;
    setState(() => _loadingElections = true);
    try {
      final list = await _electionService.getOrgElections(widget.org['_id']);
      setState(() { _elections = list; _loadingElections = false; });
    } catch (_) {
      setState(() => _loadingElections = false);
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active': return AppTheme.successGreen;
      case 'pending': return AppTheme.warningOrange;
      case 'inactive': return AppTheme.errorRed;
      default: return Colors.grey;
    }
  }

  Color _electionStatusColor(String s) {
    switch (s) {
      case 'active': return AppTheme.successGreen;
      case 'closed': return Colors.grey;
      default: return AppTheme.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = widget.org;
    final stats = org['stats'] ?? {};
    final status = org['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Column(
        children: [
          // ── Header row ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4361EE).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_rounded, color: Color(0xFF4361EE), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(org['name'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                          Text(org['type'] ?? '',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(status))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Stats row
                Row(
                  children: [
                    _chip(Icons.people_rounded, '${stats['users'] ?? 0}', 'Users', const Color(0xFF4361EE)),
                    const SizedBox(width: 8),
                    _chip(Icons.how_to_vote_rounded, '${stats['elections'] ?? 0}', 'Elections', const Color(0xFF7B2FBE)),
                    const SizedBox(width: 8),
                    _chip(Icons.check_circle_rounded, '${stats['votes'] ?? 0}', 'Votes', AppTheme.successGreen),
                  ],
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    _actionBtn(Icons.how_to_vote_rounded, 'Elections', AppTheme.primaryNavy, () {
                      setState(() => _expanded = !_expanded);
                      if (_expanded) _loadElections();
                    }),
                    const Spacer(),
                    if (status == 'pending')
                      _iconBtn(Icons.link, Colors.blue, widget.onSetupLink),
                    _iconBtn(Icons.edit_rounded, AppTheme.accentOrange, widget.onEdit),
                    _iconBtn(Icons.delete_rounded, AppTheme.errorRed, widget.onDelete),
                  ],
                ),
              ],
            ),
          ),

          // ── Elections panel ──
          if (_expanded) ...[
            const Divider(height: 1),
            _buildElectionsPanel(),
          ],
        ],
      ),
    );
  }

  Widget _buildElectionsPanel() {
    if (_loadingElections) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_elections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No elections yet', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('Elections (${_elections.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
        ),
        ..._elections.map((e) => _buildElectionRow(e)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildElectionRow(Map<String, dynamic> e) {
    final status = e['status'] ?? 'draft';
    final candidates = (e['candidates'] as List?)?.length ?? 0;
    final voters = (e['voters'] as List?)?.length ?? 0;
    final totalVotes = e['total_votes'] ?? 0;

    return InkWell(
      onTap: () {
        try {
          final election = Election.fromJson(e);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ElectionDetailsScreen(election: election)));
        } catch (_) {}
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _electionStatusColor(status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.how_to_vote_rounded, size: 18, color: _electionStatusColor(status)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['title'] ?? 'Untitled',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _miniChip(Icons.person, '$candidates'),
                      const SizedBox(width: 6),
                      _miniChip(Icons.people, '$voters'),
                      const SizedBox(width: 6),
                      _miniChip(Icons.check_circle, '$totalVotes votes'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _electionStatusColor(status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _electionStatusColor(status))),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text('$value $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppTheme.textSecondary),
        const SizedBox(width: 2),
        Text(text, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(width: 4),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}
