import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../error/app_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();
  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  // Set authentication token
  void setToken(String token) {
    _token = token;
  }

  // Clear authentication token
  void clearToken() {
    _token = null;
  }

  // Get base headers
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get authenticated headers
  Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(_baseHeaders);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Build URL with query parameters
  String _buildUrl(String endpoint, Map<String, dynamic>? queryParams) {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri
          .replace(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          )
          .toString();
    }
    return uri.toString();
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    try {
      final data = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'API Error',
          statusCode: statusCode,
          errors: data['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Failed to parse response',
        statusCode: statusCode,
      );
    }
  }

  // Handle network errors
  Future<T> _executeRequest<T>(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(
        Duration(milliseconds: int.parse(AppConstants.apiTimeout)),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException {
      throw ApiException(message: 'Network error occurred', statusCode: 0);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, queryParams);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    return _executeRequest(
      () => _httpClient.get(Uri.parse(url), headers: headers),
    );
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, queryParams);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    return _executeRequest(
      () => _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, queryParams);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    return _executeRequest(
      () => _httpClient.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, queryParams);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    return _executeRequest(
      () => _httpClient.delete(Uri.parse(url), headers: headers),
    );
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, queryParams);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    return _executeRequest(
      () => _httpClient.patch(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  // Upload file (multipart request)
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? fields,
    bool requiresAuth = true,
  }) async {
    final url = _buildUrl(endpoint, null);
    final headers = requiresAuth ? _authHeaders : _baseHeaders;

    // Remove content-type for multipart requests
    headers.remove('Content-Type');

    return _executeRequest(() async {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    });
  }

  // Close the client
  void dispose() {
    _httpClient.close();
  }
}
