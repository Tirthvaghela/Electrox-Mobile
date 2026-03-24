import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class SetupAccountScreen extends StatefulWidget {
  final String token;

  const SetupAccountScreen({super.key, required this.token});

  @override
  State<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends State<SetupAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingInvitation = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Map<String, dynamic>? _invitationData;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    });
    _loadInvitation();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitation() async {
    setState(() { _isLoadingInvitation = true; _error = null; });
    try {
      final res = await ApiService().post('/organization/invitation/verify',
          data: {'token': widget.token});
      if (res.statusCode == 200 && res.data['valid'] == true) {
        setState(() { _invitationData = res.data; _isLoadingInvitation = false; });
      } else {
        throw Exception(res.data['message'] ?? 'Invalid invitation');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoadingInvitation = false; });
    }
  }

  Future<void> _setupAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final name = _invitationData!['invitation']['organizer_name'] ?? 'Organizer';
      final success = await authProvider.setupAccount(widget.token, name, _passwordController.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account ready! Please sign in.'),
          backgroundColor: AppTheme.successGreen,
        ));
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Setup failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Setup failed: $e'),
          backgroundColor: AppTheme.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildBody(),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.accentOrange, width: 2.5),
        ),
        child: const Icon(Icons.how_to_vote_rounded, color: AppTheme.accentOrange, size: 40),
      ),
      const SizedBox(height: 16),
      const Text('Electrox', style: TextStyle(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 4),
      Text('Account Setup', style: TextStyle(
          color: Colors.white.withOpacity(0.65), fontSize: 14)),
    ]);
  }

  Widget _buildBody() {
    if (_isLoadingInvitation) return _buildLoadingCard();
    if (_error != null && _invitationData == null) return _buildErrorCard();
    if (_invitationData != null) return _buildFormCard();
    return _buildErrorCard();
  }

  Widget _buildLoadingCard() {
    return _card(Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppTheme.primaryNavy),
      const SizedBox(height: 16),
      Text('Verifying invitation...', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
    ]));
  }

  Widget _buildErrorCard() {
    String title = 'Invalid Invitation';
    String message = 'This invitation link is invalid or has expired.';

    if (_error?.contains('expired') == true) {
      title = 'Invitation Expired';
      message = 'This link has expired. Contact your administrator for a new one.';
    } else if (_error?.contains('already used') == true) {
      title = 'Already Used';
      message = 'This invitation has already been used. Try signing in instead.';
    } else if (_error?.contains('DioException') == true) {
      title = 'Connection Error';
      message = 'Could not reach the server. Check your connection and try again.';
    }

    return _card(Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.errorRed.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 40),
      ),
      const SizedBox(height: 16),
      Text(title, style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.errorRed)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryNavy, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'If you already set up your account, sign in from the login page.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryNavy),
          )),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _navyButton('Go to Login',
            () => Navigator.of(context).pushReplacementNamed('/login'))),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton(
          onPressed: _loadInvitation,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppTheme.primaryNavy),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
          ),
          child: const Text('Retry',
              style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w600)),
        )),
      ]),
    ]));
  }

  Widget _buildFormCard() {
    final inv = _invitationData!['invitation'];
    final org = inv['organization'];

    return _card(Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Setup Your Account', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
        const SizedBox(height: 4),
        Text('Complete your account for ${org['name']}',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 20),

        // Org info chip row
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          ),
          child: Column(children: [
            _infoRow(Icons.business, 'Organization', org['name']),
            const SizedBox(height: 8),
            _infoRow(Icons.email_outlined, 'Email', inv['email']),
            const SizedBox(height: 8),
            _infoRow(Icons.person_outline, 'Name', inv['organizer_name'] ?? '—'),
            const SizedBox(height: 8),
            _infoRow(Icons.badge_outlined, 'Role', 'Organizer'),
          ]),
        ),
        const SizedBox(height: 20),

        _label('Create Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 15),
          decoration: _inputDeco('At least 8 characters', Icons.lock_outline).copyWith(
            suffixIcon: _visibilityToggle(_obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter a password';
            if (v.length < 8) return 'Minimum 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),

        _label('Confirm Password'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          style: const TextStyle(fontSize: 15),
          decoration: _inputDeco('Re-enter your password', Icons.lock_outline).copyWith(
            suffixIcon: _visibilityToggle(_obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _setupAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
            ),
            child: _isLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Back to Login',
                style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    ));
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.textSecondary),
      const SizedBox(width: 8),
      Text('$label: ', style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
      Expanded(child: Text(value,
          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _label(String text) => Text(text, style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
    prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
    filled: true,
    fillColor: AppTheme.backgroundGray,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.errorRed)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
  );

  Widget _visibilityToggle(bool obscure, VoidCallback onTap) => IconButton(
    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppTheme.textHint, size: 20),
    onPressed: onTap,
  );

  Widget _navyButton(String label, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
