import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/notification_poller.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  String? _userEmail;
  String? _userName;
  String? _userRole;
  String? _organizationId;
  bool _isAuthenticated = false;

  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userRole => _userRole;
  String? get organizationId => _organizationId;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final userData = await _storageService.getUserData();
    _userEmail = userData['email'];
    _userName = userData['name'];
    _userRole = userData['role'];
    _organizationId = userData['organization_id'];
    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated && _userEmail != null) {
      NotificationPoller.start(_userEmail!);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      print('AuthProvider: Starting login...');
      final result = await _authService.login(email, password);
      print('AuthProvider: Login successful, result: $result');
      
      _userEmail = result['email'];
      _userName = result['name'];
      _userRole = result['role'];
      _organizationId = result['organization_id'];
      _isAuthenticated = true;
      NotificationPoller.start(_userEmail!);
      
      print('AuthProvider: State updated - isAuthenticated: $_isAuthenticated, role: $_userRole');
      notifyListeners();
      print('AuthProvider: notifyListeners() called');
      
      return true;
    } catch (e) {
      print('AuthProvider: Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    NotificationPoller.stop();
    await _authService.logout();
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _organizationId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateName(String name) {
    _userName = name;
    _storageService.saveUserData({
      'email': _userEmail ?? '',
      'name': name,
      'role': _userRole ?? '',
      'organization_id': _organizationId ?? '',
    });
    notifyListeners();
  }

  Future<bool> setupAccount(String token, String name, String password) async {
    try {
      await _authService.setupAccount(token, name, password);
      return true;
    } catch (e) {
      print('Setup error: $e');
      return false;
    }
  }
}
