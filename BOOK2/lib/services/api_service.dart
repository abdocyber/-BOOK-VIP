import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// طبقة API اختيارية خارج Firebase.
/// اترك baseUrl فارغًا لاستخدام Firebase فقط، أو ضع رابط السيرفر لاحقًا مثل:
/// https://api.example.com
class ApiService {
  ApiService._();

  static const String baseUrl = String.fromEnvironment('BANKAK_API_BASE_URL', defaultValue: '');
  static const Duration timeout = Duration(seconds: 12);

  static bool get enabled => baseUrl.trim().isNotEmpty;

  static Uri _uri(String path) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath');
  }

  static Future<Map<String, dynamic>?> getJson(String path, {Map<String, String>? headers}) async {
    if (!enabled) return null;
    final res = await http.get(_uri(path), headers: headers).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('api_get_failed_${res.statusCode}');
    }
    if (res.body.trim().isEmpty) return <String, dynamic>{};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    if (!enabled) return null;
    final res = await http
        .post(
          _uri(path),
          headers: {'Content-Type': 'application/json', ...?headers},
          body: jsonEncode(body),
        )
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('api_post_failed_${res.statusCode}');
    }
    if (res.body.trim().isEmpty) return <String, dynamic>{};
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
