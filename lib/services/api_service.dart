// ============================================================
// api_service.dart
// Base HTTP client - temenmu tinggal ganti BASE_URL
// dan setup header token setelah login
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO (backend): ganti dengan URL Laravel
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static String? _token; // simpan token setelah login

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // GET
  static Future<dynamic> get(String endpoint) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(res);
    } catch (e) {
      throw Exception('GET $endpoint gagal: $e');
    }
  }

  // POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(res);
    } catch (e) {
      throw Exception('POST $endpoint gagal: $e');
    }
  }

  // PUT
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(res);
    } catch (e) {
      throw Exception('PUT $endpoint gagal: $e');
    }
  }

  // DELETE
  static Future<dynamic> delete(String endpoint) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(res);
    } catch (e) {
      throw Exception('DELETE $endpoint gagal: $e');
    }
  }

  static dynamic _handleResponse(http.Response res) {
    if (kDebugMode) {
      print('[API] ${res.statusCode} ${res.request?.url}');
    }
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    } else if (res.statusCode == 401) {
      throw Exception('Sesi habis, silakan login ulang');
    } else if (res.statusCode == 422) {
      throw Exception('Validasi gagal: ${body['message']}');
    } else {
      throw Exception(body['message'] ?? 'Terjadi kesalahan');
    }
  }
}
