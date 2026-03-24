import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/local_notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_account_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/organizer/organizer_dashboard.dart';
import 'screens/voter/voter_dashboard.dart';
import 'screens/candidate/candidate_dashboard.dart';
import 'screens/splash_screen.dart';
import 'widgets/common/offline_banner.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool deepLinkActive = false;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  ApiService().initialize();
  await LocalNotificationService.init();
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Electrox',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home: OfflineBanner(child: _DeepLinkHandler(authProvider: authProvider)),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/admin-dashboard':
                  return MaterialPageRoute(builder: (_) => const AdminDashboard());
                case '/organizer-dashboard':
                  return MaterialPageRoute(builder: (_) => const OrganizerDashboard());
                case '/candidate-dashboard':
                  return MaterialPageRoute(builder: (_) => const CandidateDashboard());
                case '/voter-dashboard':
                  return MaterialPageRoute(builder: (_) => const VoterDashboard());
                default:
                  return null;
              }
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => authProvider.isAuthenticated
                  ? _homeScreen(authProvider.userRole)
                  : const LoginScreen(),
            ),
          );
        },
      ),
    );
  }

  static Widget _homeScreen(String? role) {
    switch (role) {
      case 'admin':     return const AdminDashboard();
      case 'organizer': return const OrganizerDashboard();
      case 'candidate': return const CandidateDashboard();
      case 'voter':     return const VoterDashboard();
      default:          return const LoginScreen();
    }
  }
}

class _DeepLinkHandler extends StatefulWidget {
  final AuthProvider authProvider;
  const _DeepLinkHandler({required this.authProvider});

  @override
  State<_DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<_DeepLinkHandler> {
  final _appLinks = AppLinks();
  bool _handlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    // On web: check the browser URL directly
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.path.contains('setup-account')) {
        _handleLink(uri);
      }
      return;
    }

    // On mobile: use app_links for deep links
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) _handleLink(initialUri);
    } catch (_) {}

    _appLinks.uriLinkStream.listen((uri) { if (uri != null) _handleLink(uri); }, onError: (_) {});
  }

  void _handleLink(Uri uri) {
    print('🔗 Deep link received: $uri');
    if (uri.path.contains('setup-account')) {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        _handlingDeepLink = true;
        deepLinkActive = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => SetupAccountScreen(token: token)),
            (route) => false,
          );
        });
      }
    } else if (uri.path.contains('login')) {
      // Credential email "Login to Electrox" button — navigate to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
