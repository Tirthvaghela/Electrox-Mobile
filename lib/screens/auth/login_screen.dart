import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import 'setup_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 36),
                        _buildCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.accentOrange, width: 2.5),
          ),
          child: const Icon(Icons.how_to_vote_rounded, color: AppTheme.accentOrange, size: 44),
        ),
        const SizedBox(height: 18),
        const Text(
          'Electrox',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Digital Voting Platform',
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: const [AppTheme.softShadow],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your credentials to continue',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),

            // Email
            _buildLabel('Email'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
              decoration: _inputDecoration('you@example.com', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password
            _buildLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
              decoration: _inputDecoration('Enter your password', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your password';
                return null;
              },
            ),

            const SizedBox(height: 28),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.textHint, size: 20),
      filled: true,
      fillColor: AppTheme.backgroundGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${authProvider.userName}!'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 1),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;

        final role = authProvider.userRole;
        final routes = {
          'admin': '/admin-dashboard',
          'organizer': '/organizer-dashboard',
          'candidate': '/candidate-dashboard',
          'voter': '/voter-dashboard',
        };
        final route = routes[role] ?? '/login';
        Navigator.of(context).pushReplacementNamed(route);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password. Please try again.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
