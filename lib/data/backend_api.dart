import 'dart:convert';
import 'dart:io';

// dart run build_runner build

class BackendApi {
  BackendApi({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  final String baseUrl;

  static String _defaultBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    return Platform.isAndroid
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async => (await _request('GET', path, query: query)) as List<dynamic>;

  Future<Map<String, dynamic>> get(String path) async =>
      (await _request('GET', path)) as Map<String, dynamic>;

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async => (await _request('POST', path, body: body)) as Map<String, dynamic>;

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async => (await _request('PUT', path, body: body)) as Map<String, dynamic>;

  Future<void> delete(String path) async {
    await _request('DELETE', path);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final client = HttpClient();
    try {
      return await (() async {
        final request = await client.openUrl(method, uri);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        final response = await request.close();
        final text = await utf8.decoder.bind(response).join();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException('HTTP ${response.statusCode}: $text', uri: uri);
        }
        return text.trim().isEmpty ? null : jsonDecode(text);
      })().timeout(const Duration(seconds: 10));
    } finally {
      client.close(force: true);
    }
  }
}
