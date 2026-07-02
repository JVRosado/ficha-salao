import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ajuste para o endereço onde a API (pasta backend/) está rodando.
// Emulador Android: use 10.0.2.2 no lugar de localhost.
// Dispositivo físico: use o IP da máquina que roda o backend na rede local.
const String apiBaseUrl = 'http://10.0.2.2:3000';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

class ApiClient {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isLoggedIn() async => (await getToken()) != null;

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, _errorMessage(res, 'Não foi possível entrar'));
    }
    final token = jsonDecode(res.body)['token'] as String;
    await saveToken(token);
    return token;
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$apiBaseUrl$path'), headers: await _authHeaders());
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$apiBaseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  static Future<void> delete(String path) async {
    final res = await http.delete(Uri.parse('$apiBaseUrl$path'), headers: await _authHeaders());
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, _errorMessage(res, 'Falha ao excluir'));
    }
  }

  static dynamic _handle(http.Response res) {
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode, _errorMessage(res, 'Erro na requisição'));
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  static String _errorMessage(http.Response res, String fallback) {
    try {
      final body = jsonDecode(res.body);
      return body['error'] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
