import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  // Get system statistics
  Future<Map<String, dynamic>> getStats({String? organizationId}) async {
    try {
      final queryParams = organizationId != null 
          ? {'organization_id': organizationId} 
          : null;
      
      final response = await _api.get(
        '/admin/stats',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // Get all users
  Future<List<dynamic>> getUsers({String? organizationId}) async {
    try {
      final queryParams = organizationId != null 
          ? {'organization_id': organizationId} 
          : null;
      
      final response = await _api.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data['users'];
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Create user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _api.post('/admin/users', data: userData);

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _api.put('/admin/users/$userId', data: userData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final response = await _api.delete('/admin/users/$userId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Delete organization with cascade (users + elections)
  Future<Map<String, dynamic>> deleteOrganization(String orgId) async {
    try {
      final response = await _api.delete('/admin/organizations/$orgId');
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to delete organization');
    } catch (e) {
      throw Exception('Error deleting organization: $e');
    }
  }

  // Get audit logs
  Future<List<dynamic>> getAuditLogs({int limit = 50}) async {
    try {
      final response = await _api.get(
        '/admin/audit-logs',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        return response.data['logs'];
      } else {
        throw Exception('Failed to fetch audit logs');
      }
    } catch (e) {
      throw Exception('Error fetching audit logs: $e');
    }
  }
}
