import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../config/theme.dart';
import 'package:flutter/services.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _role = 'all';
  final _searchCtrl = TextEditingController();
  static const _pageSize = 20;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportCsv() async {
    try {
      final buf = StringBuffer();
      buf.writeln('Name,Email,Role,Status');
      for (final u in _filtered) {
        final name = (u['name'] ?? '').toString().replaceAll(',', ' ');
        final email = (u['email'] ?? '').toString();
        final role = (u['role'] ?? '').toString();
        final status = (u['is_active'] == true) ? 'Active' : 'Inactive';
        buf.writeln('$name,$email,$role,$status');
      }
      await Clipboard.setData(ClipboardData(text: buf.toString()));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV copied to clipboard'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final users = await _adminService.getUsers();
      setState(() { _users = users; _isLoading = false; });
      _filter();
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _users.where((u) {
        final matchSearch = u['name'].toString().toLowerCase().contains(q) ||
            u['email'].toString().toLowerCase().contains(q);
        final matchRole = _role == 'all' || u['role'] == _role;
        return matchSearch && matchRole;
      }).toList();
      _visibleCount = _pageSize; // reset pagination on filter change
    });
  }

  Color _roleColor(String? r) {
    switch (r) {
      case 'admin': return const Color(0xFFE53935);
      case 'organizer': return const Color(0xFF4361EE);
      case 'candidate': return const Color(0xFF7B2FBE);
      case 'voter': return AppTheme.successGreen;
      default: return Colors.grey;
    }
  }

  IconData _roleIcon(String? r) {
    switch (r) {
      case 'admin': return Icons.admin_panel_settings_rounded;
      case 'organizer': return Icons.manage_accounts_rounded;
      case 'candidate': return Icons.person_rounded;
      case 'voter': return Icons.how_to_vote_rounded;
      default: return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: RefreshIndicator(
        color: AppTheme.accentOrange,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(child: _buildError())
            else if (_filtered.isEmpty)
              SliverFillRemaining(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final visible = _filtered.take(_visibleCount).toList();
                      if (i < visible.length) {
                        return _UserCard(
                          user: visible[i],
                          roleColor: _roleColor(visible[i]['role']),
                          roleIcon: _roleIcon(visible[i]['role']),
                          onEdit: () => _showEditDialog(visible[i]),
                          onToggle: () => _toggleStatus(visible[i]),
                          onDelete: () => _confirmDelete(visible[i]),
                        );
                      }
                      // Load more button
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _visibleCount += _pageSize),
                            icon: const Icon(Icons.expand_more),
                            label: Text('Load more (${_filtered.length - _visibleCount} remaining)'),
                          ),
                        ),
                      );
                    },
                    childCount: _visibleCount < _filtered.length
                        ? _visibleCount + 1
                        : _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.accentOrange,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.download_rounded, color: Colors.white),
          tooltip: 'Export CSV', onPressed: _exportCsv),
        IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _load),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppTheme.accentOrange, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('User Management',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      Text('${_users.length} total · ${_filtered.length} shown',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ]),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AppTheme.backgroundGray,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
                DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
                DropdownMenuItem(value: 'voter', child: Text('Voter')),
              ],
              onChanged: (v) { setState(() => _role = v!); _filter(); },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
      const SizedBox(height: 16),
      Text(_error!, textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ],
  ));

  Widget _buildEmpty() => const Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.people_outline, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
    ],
  ));

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'voter';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: const Text('Create User'),
          content: SingleChildScrollView(
            child: SizedBox(width: 400, child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'Valid email required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: passCtrl, obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  validator: (v) => (v!.length < 8) ? 'Min 8 characters' : null),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.security)),
                  items: const [
                    DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
                    DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
                    DropdownMenuItem(value: 'voter', child: Text('Voter')),
                  ],
                  onChanged: (v) => ss(() => role = v!),
                ),
              ]),
            )),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await _adminService.createUser({
                    'name': nameCtrl.text.trim(), 'email': emailCtrl.text.trim(),
                    'password': passCtrl.text, 'role': role, 'is_active': true,
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User created'), backgroundColor: Colors.green));
                    _load();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['name']);
    String role = user['role'] ?? 'voter';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(width: 400, child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user['email'],
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
              if (user['role'] != 'admin') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.security)),
                  items: const [
                    DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
                    DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
                    DropdownMenuItem(value: 'voter', child: Text('Voter')),
                  ],
                  onChanged: (v) => ss(() => role = v!),
                ),
              ],
            ]),
          )),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await _adminService.updateUser(user['_id'], {'name': nameCtrl.text.trim(), 'role': role});
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Updated'), backgroundColor: Colors.green));
                    _load();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    try {
      await _adminService.updateUser(user['_id'], {'is_active': !(user['is_active'] as bool)});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(user['is_active'] ? 'User deactivated' : 'User activated'),
          backgroundColor: Colors.green));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _adminService.deleteUser(user['_id']);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Deleted'), backgroundColor: Colors.green));
                  _load();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Color roleColor;
  final IconData roleIcon;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user, required this.roleColor, required this.roleIcon,
    required this.onEdit, required this.onToggle, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] == true;
    final role = user['role'] ?? 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(roleIcon, color: roleColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
              const SizedBox(height: 2),
              Text(user['email'] ?? '',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                _badge(role.toUpperCase(), roleColor),
                const SizedBox(width: 6),
                _badge(isActive ? 'ACTIVE' : 'INACTIVE',
                  isActive ? AppTheme.successGreen : AppTheme.errorRed),
              ]),
            ],
          )),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'toggle') onToggle();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [
                Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(value: 'toggle', child: Row(children: [
                Icon(isActive ? Icons.block_rounded : Icons.check_circle_rounded, size: 18),
                const SizedBox(width: 8), Text(isActive ? 'Deactivate' : 'Activate')])),
              if (role != 'admin')
                const PopupMenuItem(value: 'delete', child: Row(children: [
                  Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                  SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );
}
