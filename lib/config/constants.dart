import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'Electrox';

  // Reads SERVER_HOST from .env, falls back to local IP for emulator
  static String get baseUrl {
    final host = dotenv.env['SERVER_HOST'] ?? 'http://10.0.2.2:5000';
    return '$host/api';
  }

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String setupAccountEndpoint = '/auth/setup-account';
  static const String createElectionEndpoint = '/election/create';
  static const String voteEndpoint = '/election/vote';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleOrganizer = 'organizer';
  static const String roleCandidate = 'candidate';
  static const String roleVoter = 'voter';

  // Election Status
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusClosed = 'closed';

  // Result Visibility
  static const String visibilityHidden = 'hidden';
  static const String visibilityLive = 'live';
  static const String visibilityFinalOnly = 'final_only';
}
