import 'api_service.dart';

class TemplateService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyTemplates(String email) async {
    final res = await _api.get('/templates/my-templates', queryParameters: {'email': email});
    if (res.statusCode == 200) return res.data['templates'] ?? [];
    throw Exception('Failed to load templates');
  }

  Future<void> createTemplate({
    required String name,
    required String description,
    required String organizerEmail,
    required String organizationId,
    required Map<String, dynamic> templateData,
  }) async {
    final res = await _api.post('/templates/create', data: {
      'name': name,
      'description': description,
      'organizer_email': organizerEmail,
      'organization_id': organizationId,
      'template_data': templateData,
    });
    if (res.statusCode != 201) throw Exception('Failed to create template');
  }

  Future<Map<String, dynamic>> useTemplate(String templateId) async {
    final res = await _api.post('/templates/use/$templateId');
    if (res.statusCode == 200) return res.data;
    throw Exception('Failed to use template');
  }
}
