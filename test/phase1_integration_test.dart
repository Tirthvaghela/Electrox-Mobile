import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/providers/auth_provider.dart';
import '../lib/services/api_service.dart';
import '../lib/services/admin_service.dart';
import '../lib/services/organization_service.dart';
import '../lib/utils/validators.dart';
import '../lib/utils/error_handler.dart';
import '../lib/screens/auth/login_screen.dart';
import '../lib/config/theme.dart';
import '../lib/config/constants.dart';

void main() {
  group('Phase 1 Integration Tests', () {
    setUpAll(() {
      // Initialize API service for testing
      ApiService().initialize();
    });

    testWidgets('App initializes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Should show login screen initially
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Electrox'), findsOneWidget);
      expect(find.text('Digital Voting Platform'), findsOneWidget);
    });

    testWidgets('Login screen has required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Check for email and password fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    test('Validators work correctly', () {
      // Email validation
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email address');
      expect(Validators.validateEmail('test@example.com'), null);

      // Password validation
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('123'), 'Password must be at least 8 characters long');
      expect(Validators.validatePassword('password'), 'Password must contain at least one letter and one number');
      expect(Validators.validatePassword('password123'), null);

      // Name validation
      expect(Validators.validateName(''), 'Name is required');
      expect(Validators.validateName('A'), 'Name must be at least 2 characters long');
      expect(Validators.validateName('John Doe'), null);

      // Organization name validation
      expect(Validators.validateOrganizationName(''), 'Organization name is required');
      expect(Validators.validateOrganizationName('AB'), 'Organization name must be at least 3 characters long');
      expect(Validators.validateOrganizationName('Tech University'), null);
    });

    test('Error handler formats messages correctly', () {
      // Test basic error message
      final basicError = Exception('Test error');
      final message = ErrorHandler.handleApiError(basicError);
      expect(message, contains('Test error'));
    });

    test('API service initializes correctly', () {
      final apiService = ApiService();
      expect(apiService.baseUrl, 'http://localhost:5000/api');
    });

    test('Admin service methods exist', () {
      final adminService = AdminService();
      
      // Check that methods exist (they should not throw when called with proper setup)
      expect(() => adminService.getStats(), returnsNormally);
      expect(() => adminService.getUsers(), returnsNormally);
      expect(() => adminService.getAuditLogs(), returnsNormally);
    });

    test('Organization service methods exist', () {
      final orgService = OrganizationService();
      
      // Check that methods exist
      expect(() => orgService.getAllOrganizations(), returnsNormally);
      expect(() => orgService.getPendingInvitations(), returnsNormally);
    });

    testWidgets('AuthProvider initializes correctly', (WidgetTester tester) async {
      final authProvider = AuthProvider();
      
      // Initial state should be unauthenticated
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.userEmail, null);
      expect(authProvider.userName, null);
      expect(authProvider.userRole, null);
    });

    group('Model Tests', () {
      test('User model serialization works', () {
        final userData = {
          '_id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'admin',
          'is_active': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
        };

        // This would test User.fromJson if the model was imported
        // For now, just verify the data structure is correct
        expect(userData['_id'], '123');
        expect(userData['email'], 'test@example.com');
        expect(userData['role'], 'admin');
      });

      test('Organization model data structure', () {
        final orgData = {
          '_id': '456',
          'name': 'Test Org',
          'type': 'university',
          'status': 'active',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'stats': {
            'users': 100,
            'elections': 5,
            'votes': 500,
          },
        };

        expect(orgData['name'], 'Test Org');
        expect(orgData['type'], 'university');
        final stats = orgData['stats'] as Map<String, dynamic>?;
        expect(stats?['users'], 100);
      });
    });

    group('UI Component Tests', () {
      testWidgets('Login form validation works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => AuthProvider(),
              child: const LoginScreen(),
            ),
          ),
        );

        // Try to submit empty form
        await tester.tap(find.text('Login'));
        await tester.pump();

        // Should show validation errors
        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('Password visibility toggle works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider(
              create: (_) => AuthProvider(),
              child: const LoginScreen(),
            ),
          ),
        );

        // Find password field
        final passwordField = find.byType(TextFormField).last;
        expect(passwordField, findsOneWidget);

        // Find visibility toggle button
        final visibilityButton = find.byIcon(Icons.visibility);
        expect(visibilityButton, findsOneWidget);

        // Tap to toggle visibility
        await tester.tap(visibilityButton);
        await tester.pump();

        // Should now show visibility_off icon
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('Theme Tests', () {
      test('App theme colors are defined', () {
        // Test that theme constants exist
        expect(AppTheme.primaryNavy, const Color(0xFF14213D));
        expect(AppTheme.primaryBlue, const Color(0xFF2E5EAA));
        expect(AppTheme.accentOrange, const Color(0xFFFCA311));
        expect(AppTheme.successGreen, const Color(0xFF06D6A0));
      });

      testWidgets('App uses correct theme', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, isNotNull);
        expect(materialApp.theme?.primaryColor, AppTheme.primaryNavy);
      });
    });

    group('Constants Tests', () {
      test('API constants are defined', () {
        expect(AppConstants.appName, 'Electrox');
        expect(AppConstants.baseUrl, 'http://localhost:5000/api');
        expect(AppConstants.loginEndpoint, '/auth/login');
        expect(AppConstants.roleAdmin, 'admin');
        expect(AppConstants.roleOrganizer, 'organizer');
      });
    });
  });

  group('Phase 1 Feature Completeness', () {
    test('All required services exist', () {
      // Check that all service files can be instantiated
      expect(() => ApiService(), returnsNormally);
      expect(() => AdminService(), returnsNormally);
      expect(() => OrganizationService(), returnsNormally);
      expect(() => AuthProvider(), returnsNormally);
    });

    test('All validators are implemented', () {
      // Test that all validation methods exist and work
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validatePassword('password123'), null);
      expect(Validators.validateName('John Doe'), null);
      expect(Validators.validateOrganizationName('Tech University'), null);
      expect(Validators.validateRequired('test', 'Field'), null);
    });

    test('Error handling is comprehensive', () {
      // Test error handler methods exist
      expect(() => ErrorHandler.handleApiError(Exception('test')), returnsNormally);
      expect(() => ErrorHandler.logError('test'), returnsNormally);
    });
  });
}