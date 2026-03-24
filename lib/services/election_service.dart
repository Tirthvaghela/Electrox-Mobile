import 'api_service.dart';
import '../config/constants.dart';

class ElectionService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyElections(String email) async {
    try {
      final response = await _api.get(
        '/election/my-elections',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data['elections'] ?? [];
      } else {
        throw Exception('Failed to load elections');
      }
    } catch (e) {
      throw Exception('Error loading elections: $e');
    }
  }

  Future<List<dynamic>> getVoterElections(String email) async {
    try {
      final response = await _api.get(
        '/election/voter-elections',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data['elections'] ?? [];
      } else {
        throw Exception('Failed to load voter elections');
      }
    } catch (e) {
      throw Exception('Error loading voter elections: $e');
    }
  }

  Future<List<dynamic>> getCandidateElections(String email) async {
    try {
      final response = await _api.get(
        '/election/candidate-elections',
        queryParameters: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data['elections'] ?? [];
      } else {
        throw Exception('Failed to load candidate elections');
      }
    } catch (e) {
      throw Exception('Error loading candidate elections: $e');
    }
  }

  Future<Map<String, dynamic>> createElection(Map<String, dynamic> electionData) async {
    try {
      final response = await _api.post(
        AppConstants.createElectionEndpoint,
        data: electionData,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create election');
      }
    } catch (e) {
      throw Exception('Error creating election: $e');
    }
  }

  Future<Map<String, dynamic>> uploadParticipants(String csvData) async {
    try {
      final response = await _api.post(
        '/election/upload-participants',
        data: {'csv_data': csvData},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to upload participants');
      }
    } catch (e) {
      throw Exception('Error uploading participants: $e');
    }
  }

  Future<void> castVote(String electionId, String voterEmail, String candidateEmail) async {
    try {
      final response = await _api.post(
        AppConstants.voteEndpoint,
        data: {
          'election_id': electionId,
          'voter_email': voterEmail,
          'candidate_email': candidateEmail,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cast vote');
      }
    } catch (e) {
      throw Exception('Error casting vote: $e');
    }
  }

  Future<Map<String, dynamic>> getResults(String electionId, String role, String email) async {
    try {
      final response = await _api.get(
        '/election/results/$electionId',
        queryParameters: {
          'role': role,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      throw Exception('Error loading results: $e');
    }
  }

  Future<Map<String, dynamic>> exportResults(String electionId) async {
    try {
      final response = await _api.get('/election/results/$electionId/export');
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to export results');
    } catch (e) {
      throw Exception('Error exporting results: $e');
    }
  }

  Future<void> updateElection(String electionId, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/election/update/$electionId', data: data);
      if (response.statusCode != 200) throw Exception('Failed to update election');
    } catch (e) {
      throw Exception('Error updating election: $e');
    }
  }

  Future<String> exportVoters(String electionId) async {
    try {
      final response = await _api.get('/bulk/export-voters/$electionId');

      if (response.statusCode == 200) {
        return response.data['csv'];
      } else {
        throw Exception('Failed to export voters');
      }
    } catch (e) {
      throw Exception('Error exporting voters: $e');
    }
  }

  Future<void> sendReminders(String electionId) async {
    try {
      final response = await _api.post('/bulk/send-reminders/$electionId');

      if (response.statusCode != 200) {
        throw Exception('Failed to send reminders');
      }
    } catch (e) {
      throw Exception('Error sending reminders: $e');
    }
  }

  Future<void> updateElectionStatus(String electionId, String status) async {
    try {
      final response = await _api.put(
        '/election/update-status',
        data: {
          'election_id': electionId,
          'status': status,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update election status');
      }
    } catch (e) {
      throw Exception('Error updating election status: $e');
    }
  }

  Future<void> deleteElection(String electionId) async {
    try {
      final response = await _api.delete('/election/delete/$electionId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete election');
      }
    } catch (e) {
      throw Exception('Error deleting election: $e');
    }
  }

  Future<Map<String, dynamic>> getElectionDetails(String electionId) async {
    try {
      final response = await _api.get('/election/$electionId');
      if (response.statusCode == 200) return response.data;
      throw Exception('Failed to load election details');
    } catch (e) {
      throw Exception('Error loading election details: $e');
    }
  }

  Future<List<dynamic>> getOrgElections(String orgId) async {
    try {
      final response = await _api.get('/election/by-organization/$orgId');
      if (response.statusCode == 200) return response.data['elections'] ?? [];
      throw Exception('Failed to load org elections');
    } catch (e) {
      throw Exception('Error loading org elections: $e');
    }
  }
}