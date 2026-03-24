import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart' show deepLinkActive;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) _navigate();
    });
  }

  void _navigate() {
    // Don't redirect if a deep link (e.g. setup-account) has taken over
    if (deepLinkActive) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      switch (auth.userRole) {
        case 'admin':     Navigator.pushReplacementNamed(context, '/admin-dashboard'); break;
        case 'organizer': Navigator.pushReplacementNamed(context, '/organizer-dashboard'); break;
        case 'candidate': Navigator.pushReplacementNamed(context, '/candidate-dashboard'); break;
        case 'voter':     Navigator.pushReplacementNamed(context, '/voter-dashboard'); break;
        default:          Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo — same as login screen
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentOrange, width: 3),
                  ),
                  child: const Icon(Icons.how_to_vote_rounded, color: AppTheme.accentOrange, size: 56),
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'Electrox',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                const Text(
                  'Digital Voting Platform',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.accentOrange,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
