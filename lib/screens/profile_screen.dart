import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _savingName = false;
  bool _savingPass = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameCtrl.text = auth.userName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'admin': return const Color(0xFFE53935);
      case 'organizer': return const Color(0xFF4361EE);
      case 'candidate': return const Color(0xFF7B2FBE);
      case 'voter': return AppTheme.successGreen;
      default: return AppTheme.primaryNavy;
    }
  }

  IconData _roleIcon(String? role) {
    switch (role) {
      case 'admin': return Icons.admin_panel_settings_rounded;
      case 'organizer': return Icons.manage_accounts_rounded;
      case 'candidate': return Icons.person_rounded;
      case 'voter': return Icons.how_to_vote_rounded;
      default: return Icons.person_rounded;
    }
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await ApiService().put('/user/profile', data: {'email': auth.userEmail, 'name': name});
      auth.updateName(name);
      if (mounted) _showSuccess('Name updated!');
    } catch (e) {
      if (mounted) _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _changePassword() async {
    final oldPass = _oldPassCtrl.text;
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;
    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showError('Fill in all password fields'); return;
    }
    if (newPass.length < 8) { _showError('Min 8 characters'); return; }
    if (newPass != confirm) { _showError('Passwords do not match'); return; }

    setState(() => _savingPass = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await ApiService().post('/password/change', data: {
        'email': auth.userEmail,
        'old_password': oldPass,
        'new_password': newPass,
      });
      if (mounted) {
        _oldPassCtrl.clear(); _newPassCtrl.clear(); _confirmPassCtrl.clear();
        _showSuccess('Password changed!');
      }
    } catch (e) {
      if (mounted) _showError('Failed: $e');
    } finally {
      if (mounted) setState(() => _savingPass = false);
    }
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppTheme.successGreen));

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppTheme.errorRed));

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.userRole ?? 'user';
    final roleColor = _roleColor(role);
    final initial = (auth.userName ?? 'U').isNotEmpty
        ? (auth.userName ?? 'U')[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF0D1B2E), AppTheme.primaryNavy],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: roleColor,
                          boxShadow: [
                            BoxShadow(color: roleColor.withOpacity(0.4),
                                blurRadius: 20, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Center(
                          child: Text(initial,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 34, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(auth.userName ?? '',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(auth.userEmail ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      const SizedBox(height: 12),
                      // Role chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: roleColor.withOpacity(0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_roleIcon(role), size: 14, color: roleColor),
                          const SizedBox(width: 6),
                          Text(role.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                color: roleColor)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Display Name ───────────────────────────────────────────────
              _card(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF4361EE),
                title: 'Display Name',
                child: Column(children: [
                  _field(_nameCtrl, 'Your name', Icons.person_outline_rounded),
                  const SizedBox(height: 14),
                  _primaryBtn('Save Name', AppTheme.primaryNavy,
                      _savingName ? null : _saveName, _savingName),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Change Password ────────────────────────────────────────────
              _card(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF7B2FBE),
                title: 'Change Password',
                child: Column(children: [
                  _passField(_oldPassCtrl, 'Current password', _obscureOld,
                      () => setState(() => _obscureOld = !_obscureOld)),
                  const SizedBox(height: 12),
                  _passField(_newPassCtrl, 'New password', _obscureNew,
                      () => setState(() => _obscureNew = !_obscureNew)),
                  const SizedBox(height: 12),
                  _passField(_confirmPassCtrl, 'Confirm new password', _obscureConfirm,
                      () => setState(() => _obscureConfirm = !_obscureConfirm)),
                  const SizedBox(height: 14),
                  _primaryBtn('Update Password', const Color(0xFF7B2FBE),
                      _savingPass ? null : _changePassword, _savingPass),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Sign Out ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, auth),
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppTheme.errorRed,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                ),
              ),
            ])),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _card({required IconData icon, required Color iconColor,
      required String title, required Widget child}) {
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
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 15,
              fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon) =>
    TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
        filled: true, fillColor: AppTheme.backgroundGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
      ),
    );

  Widget _passField(TextEditingController ctrl, String hint,
      bool obscure, VoidCallback toggle) =>
    TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textHint, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppTheme.textHint, size: 20),
          onPressed: toggle,
        ),
        filled: true, fillColor: AppTheme.backgroundGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
      ),
    );

  Widget _primaryBtn(String label, Color color, VoidCallback? onTap, bool loading) =>
    SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
        ),
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusModal)),
        title: const Text('Sign Out', style: AppTheme.titleLarge),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await auth.logout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
