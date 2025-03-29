import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiService(
      {required this.baseUrl,
      this.defaultHeaders = const {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      }});

  // Helper method to build headers
  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    return {
      ...defaultHeaders, // Include default headers
      if (headers != null) ...headers, // Include additional headers
    };
  }

  // Helper method to build URL with query parameters
  Uri _buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    final url = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null) {
      return url.replace(queryParameters: {
        ...url.queryParameters,
        ...queryParams.map((key, value) => MapEntry(key, value.toString())),
      });
    }
    return url;
  }

  // GET request
  Future<dynamic> get(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? queryParams}) async {
    final url = _buildUrl(endpoint, queryParams);
    try {
      final response = await http.get(url, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // POST request
  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? data}) async {
    final url = _buildUrl(endpoint);
    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(headers),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? data}) async {
    final url = _buildUrl(endpoint);
    try {
      final response = await http.put(
        url,
        headers: _buildHeaders(headers),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers, Map<String, dynamic>? queryParams}) async {
    final url = _buildUrl(endpoint, queryParams);
    try {
      final response = await http.delete(url, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'HTTP Error: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
