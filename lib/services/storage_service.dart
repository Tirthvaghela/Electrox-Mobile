import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Token management — uses SharedPreferences on web (secure storage unsupported)
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      await _secureStorage.write(key: 'auth_token', value: token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } else {
      await _secureStorage.delete(key: 'auth_token');
    }
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? '');
    await prefs.setString('organization_id', userData['organization_id'] ?? '');
  }

  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'role': prefs.getString('user_role'),
      'organization_id': prefs.getString('organization_id'),
    };
  }

  Future<void> clearAll() async {
    if (!kIsWeb) await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
