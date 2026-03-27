import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:servizone_app/config/environment_config.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Callbacks globales para manejar errores comunes a nivel de app
  Function()? onSessionExpired;
  Function(String)? onForbidden;
  Function()? onTooManyRequests;
  Function(String)? onServerError;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // 1. Adjuntar Token si existe
      final token = await _storage.read(key: 'accessToken');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 2. Enviar petición inicial
      var response = await _inner.send(request);

      // 3. Interceptar 401 Unauthorized
      if (response.statusCode == 401) {
        final path = request.url.path.toLowerCase();
        // Prevenir auto-refresh en login o switch-role para evitar conflictos con el SecurityStamp
        if (path.contains('/auth/login') || path.contains('/auth/switch-role')) {
          return response;
        }
        
        // Validación para evitar bucle infinito: si ya reintentamos, no volvemos a intentar
        if (request.headers.containsKey('X-Retry')) {
          await _clearSession();
          onSessionExpired?.call();
          return response;
        }

        final success = await _tryRefreshToken();
        if (success) {
          // Reintentar clonando el request original
          var newRequest = _cloneRequest(request);
          newRequest.headers['X-Retry'] = 'true'; // Marcador para evitar bucle
          final newToken = await _storage.read(key: 'accessToken');
          newRequest.headers['Authorization'] = 'Bearer $newToken';
          response = await _inner.send(newRequest);
        } else {
          // Falló el refresh o no existe endpoint: Expulsar al usuario
          await _clearSession();
          onSessionExpired?.call();
        }
      } 
      // 4. Interceptar 403 Forbidden
      else if (response.statusCode == 403) {
        onForbidden?.call('No tienes permisos suficientes (403)');
      } 
      // 5. Interceptar 429 Too Many Requests
      else if (response.statusCode == 429) {
        onTooManyRequests?.call();
      }
      // 6. Interceptar 5xx Server Error
      else if (response.statusCode >= 500 && response.statusCode < 600) {
        onServerError?.call('Error del servidor (${response.statusCode})');
      }

      return response;
    } on SocketException {
      throw Exception('Sin conexión a Internet');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      final refreshToken = await _storage.read(key: 'refreshToken');

      if (token == null || refreshToken == null) return false;

      final url = Uri.parse('${EnvironmentConfig.apiBaseUrl}/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': token,
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
          if (data['refreshToken'] != null) {
            await _storage.write(key: 'refreshToken', value: data['refreshToken']);
          }
          return true;
        }
      }
    } catch (e) {
      // Log error
    }
    return false;
  }

  http.BaseRequest _cloneRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final newReq = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;
      return newReq;
    } else if (request is http.MultipartRequest) {
      final newReq = http.MultipartRequest(request.method, request.url)
        ..headers.addAll(request.headers)
        ..fields.addAll(request.fields)
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;
      return newReq;
    } else {
      throw UnimplementedError('Cloning not implemented for ${request.runtimeType}');
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'role');
  }

  // Helpers HTTP
  Future<http.Response> getRequest(String endpoint) async {
    return await http.Response.fromStream(
      await send(http.Request('GET', Uri.parse('${EnvironmentConfig.apiBaseUrl}$endpoint')))
    );
  }

  Future<http.Response> postRequest(String endpoint, dynamic body) async {
    final req = http.Request('POST', Uri.parse('${EnvironmentConfig.apiBaseUrl}$endpoint'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    return await http.Response.fromStream(await send(req));
  }

  Future<http.Response> patchRequest(String endpoint, dynamic body) async {
    final req = http.Request('PATCH', Uri.parse('${EnvironmentConfig.apiBaseUrl}$endpoint'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    return await http.Response.fromStream(await send(req));
  }

  Future<http.Response> putRequest(String endpoint, dynamic body) async {
    final req = http.Request('PUT', Uri.parse('${EnvironmentConfig.apiBaseUrl}$endpoint'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    return await http.Response.fromStream(await send(req));
  }
}
