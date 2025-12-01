// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

// This service acts as a centralized HTTP client for making external API calls,
// handling common headers, errors, and response parsing.

class ApiService {
  // Base URL for your APIs. This could be from app_constants.dart if you have one.
  // For now, we'll keep it as a placeholder.
  // In a real app, this would typically point to your backend or a specific API.
  // For Gemini, the base URL is defined in AppConstants.
  final String _baseUrl;
  final String? _apiKey; // Optional API key for general APIs, Gemini has its own

  ApiService({required String baseUrl, String? apiKey})
      : _baseUrl = baseUrl,
        _apiKey = apiKey;

  // Helper for common headers
  Map<String, String> _getHeaders({Map<String, String>? customHeaders}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_apiKey != null) {
      // This is a generic API key header. For Gemini, the key is a query parameter.
      // Specific APIs might require 'Authorization': 'Bearer $_apiKey'
      // This header might not be used for Gemini directly, but useful for other APIs.
      // headers['X-API-Key'] = _apiKey!;
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  // --- HTTP GET Request ---
  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');
    debugPrint('GET Request to: $uri');
    try {
      final response = await http.get(uri, headers: _getHeaders(customHeaders: headers));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET Request Error on $path: $e');
      throw ApiException('Failed to complete GET request: $e');
    }
  }

  // --- HTTP POST Request ---
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');
    debugPrint('POST Request to: $uri with body: ${body != null ? jsonEncode(body) : 'null'}');
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(customHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST Request Error on $path: $e');
      throw ApiException('Failed to complete POST request: $e');
    }
  }

  // --- HTTP PUT Request ---
  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');
    debugPrint('PUT Request to: $uri with body: ${body != null ? jsonEncode(body) : 'null'}');
    try {
      final response = await http.put(
        uri,
        headers: _getHeaders(customHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT Request Error on $path: $e');
      throw ApiException('Failed to complete PUT request: $e');
    }
  }

  // --- HTTP DELETE Request ---
  Future<Map<String, dynamic>> delete(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');
    debugPrint('DELETE Request to: $uri');
    try {
      final response = await http.delete(uri, headers: _getHeaders(customHeaders: headers));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE Request Error on $path: $e');
      throw ApiException('Failed to complete DELETE request: $e');
    }
  }

  // --- Handles API Response ---
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('Response Status for ${response.request?.url}: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successful response
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {}; // Return empty map for successful requests with no body
    } else {
      // Error response
      String errorMessage = 'API Error: ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('error') && errorData['error'] is Map && errorData['error'].containsKey('message')) {
          errorMessage = errorData['error']['message'];
        } else if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
      } catch (e) {
        debugPrint('Failed to parse error response body: $e');
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: ${statusCode ?? 'N/A'})';
}

