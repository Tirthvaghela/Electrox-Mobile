import 'package:dio/dio.dart';
import '../config/constants.dart';
import 'storage_service.dart';
import '../utils/error_handler.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  final StorageService _storageService = StorageService();

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120), // election creation sends emails
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add request interceptor to include auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request in debug mode
        print('🚀 ${options.method.toUpperCase()} ${options.uri}');
        if (options.data != null) {
          print('📤 Request data: ${options.data}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response in debug mode
        print('✅ ${response.statusCode} ${response.requestOptions.uri}');
        print('📥 Response data: ${response.data}');
        
        handler.next(response);
      },
      onError: (error, handler) {
        // Log error in debug mode
        print('❌ ${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}');
        print('💥 Error: ${error.message}');
        if (error.response?.data != null) {
          print('📥 Error response: ${error.response?.data}');
        }
        
        // Handle 401 errors (unauthorized)
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        
        handler.next(error);
      },
    ));
  }

  // Constructor for backward compatibility
  ApiService.legacy() {
    initialize();
  }

  Future<void> _handleUnauthorized() async {
    // Clear stored auth data
    await _storageService.clearAll();
    // Note: Navigation should be handled by the UI layer
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    final message = ErrorHandler.handleApiError(error);
    ErrorHandler.logError('API Error', error);
    return Exception(message);
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get base URL
  String get baseUrl => _dio.options.baseUrl;

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}