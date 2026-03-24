import 'api_service.dart';
import 'storage_service.dart';
import '../config/constants.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('=== AUTH SERVICE LOGIN START ===');
      print('Email: $email');
      print('Base URL: ${AppConstants.baseUrl}');
      print('Login Endpoint: ${AppConstants.loginEndpoint}');
      
      final response = await _api.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        print('Extracting token...');
        final token = data['token'];
        print('Token: ${token != null ? "EXISTS" : "NULL"}');
        
        print('Saving token...');
        await _storage.saveToken(token);
        
        print('Saving user data...');
        await _storage.saveUserData({
          'email': data['email'],
          'name': data['name'],
          'role': data['role'],
          'organization_id': data['organization_id'],
        });

        print('=== AUTH SERVICE LOGIN SUCCESS ===');
        return data;
      } else {
        print('=== AUTH SERVICE LOGIN FAILED - Status: ${response.statusCode} ===');
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('=== AUTH SERVICE LOGIN ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> setupAccount(String token, String name, String password) async {
    try {
      final response = await _api.post(
        AppConstants.setupAccountEndpoint,
        data: {
          'token': token,
          'name': name,
          'password': password,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Account setup failed');
      }
    } catch (e) {
      throw Exception('Setup error: $e');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
