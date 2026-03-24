import 'api_service.dart';

class OrganizationService {
  final ApiService _api = ApiService();

  // Get all organizations
  Future<List<dynamic>> getAllOrganizations() async {
    try {
      final response = await _api.get('/organization/all');

      if (response.statusCode == 200) {
        return response.data['organizations'];
      } else {
        throw Exception('Failed to fetch organizations');
      }
    } catch (e) {
      throw Exception('Error fetching organizations: $e');
    }
  }

  // Get organization by ID
  Future<Map<String, dynamic>> getOrganization(String orgId) async {
    try {
      final response = await _api.get('/organization/$orgId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch organization');
      }
    } catch (e) {
      throw Exception('Error fetching organization: $e');
    }
  }

  // Create organization
  Future<Map<String, dynamic>> createOrganization(Map<String, dynamic> orgData) async {
    try {
      final response = await _api.post('/organization/create', data: orgData);

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create organization');
      }
    } catch (e) {
      throw Exception('Error creating organization: $e');
    }
  }

  // Update organization
  Future<Map<String, dynamic>> updateOrganization(String orgId, Map<String, dynamic> orgData) async {
    try {
      final response = await _api.put('/organization/$orgId', data: orgData);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update organization');
      }
    } catch (e) {
      throw Exception('Error updating organization: $e');
    }
  }

  // Delete organization
  Future<void> deleteOrganization(String orgId) async {
    try {
      final response = await _api.delete('/organization/$orgId');

      if (response.statusCode != 200) {
        if (response.statusCode == 400 && response.data != null) {
          final message = response.data['message'] ?? 'Failed to delete organization';
          throw Exception(message);
        } else if (response.statusCode == 404) {
          throw Exception('Organization not found');
        } else {
          throw Exception('Failed to delete organization');
        }
      }
    } catch (e) {
      final msg = e.toString();
      // Strip raw DioException noise, show clean message
      if (msg.contains('401') || msg.contains('Authentication')) {
        throw Exception('Session expired. Please log out and log back in.');
      }
      if (msg.contains('403') || msg.contains('Forbidden')) {
        throw Exception('You do not have permission to delete organizations.');
      }
      if (e is Exception) rethrow;
      throw Exception('Error deleting organization: $e');
    }
  }

  // Verify invitation token
  Future<Map<String, dynamic>> verifyInvitation(String token) async {
    try {
      final response = await _api.post('/organization/invitation/verify', data: {'token': token});

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Invalid or expired invitation');
      }
    } catch (e) {
      throw Exception('Error verifying invitation: $e');
    }
  }

  // Get pending invitations
  Future<List<dynamic>> getPendingInvitations() async {
    try {
      final response = await _api.get('/organization/invitation/pending');

      if (response.statusCode == 200) {
        return response.data['invitations'];
      } else {
        throw Exception('Failed to fetch invitations');
      }
    } catch (e) {
      throw Exception('Error fetching invitations: $e');
    }
  }

  // Get invitation for organization
  Future<Map<String, dynamic>> getOrganizationInvitation(String orgId) async {
    try {
      final response = await _api.get('/organization/$orgId/invitation');

      if (response.statusCode == 200) {
        return response.data['invitation'];
      } else {
        throw Exception('No pending invitation found');
      }
    } catch (e) {
      throw Exception('Error fetching invitation: $e');
    }
  }
}
