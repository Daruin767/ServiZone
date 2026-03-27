import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:servizone_app/core/network/api_client.dart';
import 'package:servizone_app/config/environment_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._apiClient);

  bool _isLoggedIn = false;
  String? _currentRole;
  Map<String, dynamic>? currentUserProfile;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentRole => _currentRole;

  Future<bool> autoLogin() async {
    final token = await _storage.read(key: 'accessToken');
    final role = await _storage.read(key: 'role');
    
    if (token != null && role != null) {
      _currentRole = role;
      
      final res = await fetchAndStoreProfile();
      bool isValid = res['success'];
      bool isAuthError = res['statusCode'] == 401 || res['statusCode'] == 403;
      
      if (isValid || !isAuthError) {
        _isLoggedIn = true;
        return true;
      } else {
        await logout();
        return false;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> fetchAndStoreProfile() async {
    if (_currentRole == 'cliente') {
      final res = await getPerfilCliente();
      if (res['success']) currentUserProfile = res['data'];
      return res;
    } else if (_currentRole == 'proveedor') {
      final res = await getPerfilProveedor();
      if (res['success']) currentUserProfile = res['data'];
      return res;
    }
    return {'success': true, 'statusCode': 200}; // Admin fallback
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // El login puede no necesitar token, pero lo enviamos por el cliente normal
      // o usamos http sin interceptor si queremos asegurarnos. El interceptor es seguro.
      final response = await _apiClient.postRequest('/auth/login', {
        'correo': email,
        'contrasena': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
          await _storage.write(key: 'refreshToken', value: data['refreshToken']);
          
          final roleStr = data['role']?.toString().toLowerCase() ?? 'cliente';
          await _storage.write(key: 'role', value: roleStr);
          
          _isLoggedIn = true;
          _currentRole = roleStr;
          
          await fetchAndStoreProfile();
          
          return {'success': true, 'role': roleStr};
        }
      }
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Falló la conexión al servidor: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.postRequest('/auth/register', userData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Ocurrió un error al registrar: $e'};
    }
  }

  Future<Map<String, dynamic>> switchRole(String targetRole) async {
    try {
      // El backend espera "Cliente" o "Proveedor" (Title Case)
      String formattedRole = targetRole.length > 1 
          ? '${targetRole[0].toUpperCase()}${targetRole.substring(1).toLowerCase()}' 
          : targetRole;

      // El serializador jsonEncode convertirá este string a '"Cliente"', lo que es correcto y esperado.
      final response = await _apiClient.postRequest('/auth/switch-role', formattedRole);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Usar datos explícitos del backend como fuente de verdad
        final bool isSuccess = data['success'] == true;
        final String? newToken = data['token'];
        final String? newActiveRole = data['activeRole'];
        // const roles = data['rolesDisponibles']; // opcional para UI
        
        if (!isSuccess || newToken == null || newToken.isEmpty) {
          return {
            'success': false,
            'message': data['message'] ?? 'Falló el cambio de rol: sin éxito explícito del servidor'
          };
        }

        // Reemplazar completamente los tokens
        await _storage.write(key: 'accessToken', value: newToken);
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        }
        
        final finalRole = newActiveRole != null ? newActiveRole.toLowerCase() : targetRole.toLowerCase();
        await _storage.write(key: 'role', value: finalRole);
        _currentRole = finalRole;
        
        // Sincronizar estado en memoria SIEMPRE (OBLIGATORIO)
        await fetchAndStoreProfile();

        return {
          'success': true, 
          'role': _currentRole,
          'rolesDisponibles': data['rolesDisponibles'],
          'message': data['message'] ?? 'Cambio de rol exitoso'
        };
      }
      
      final errorMessage = _parseError(response.body);
      return {
        'success': false, 
        'statusCode': response.statusCode, 
        'message': errorMessage,
        'body': response.body 
      };
    } catch (e) {
      debugPrint('==== SWITCH ROLE EXCEPTION ====');
      debugPrint('Exception: $e');
      debugPrint('===============================');
      return {
        'success': false, 
        'statusCode': 0, 
        'message': 'Error de red o interno: $e'
      };
    }
  }

  // Profile Endpoints
  Future<Map<String, dynamic>> getPerfilCliente() async {
    try {
      final response = await _apiClient.getRequest('/perfil/cliente');
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'statusCode': response.statusCode, 'message': 'Error obteniendo perfil: ${response.statusCode}'};
    } catch(e) {
      return {'success': false, 'statusCode': 0, 'message': 'Sin red o error interno'};
    }
  }

  Future<Map<String, dynamic>> getPerfilProveedor() async {
    try {
      final response = await _apiClient.getRequest('/perfil/proveedor');
      if (response.statusCode == 200) return {'success': true, 'data': jsonDecode(response.body)};
      return {'success': false, 'statusCode': response.statusCode, 'message': 'Error obteniendo perfil: ${response.statusCode}'};
    } catch(e) {
      return {'success': false, 'statusCode': 0, 'message': 'Sin red o error interno'};
    }
  }

  Future<Map<String, dynamic>> updatePerfilCliente(Map<String, dynamic> data) async {
    try {
      // Remover valores nulos o claves vacías para no romper la deserialización del backend
      final cleanedData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null || key.isEmpty);
        
      final response = await _apiClient.patchRequest('/perfil/cliente', cleanedData);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAndStoreProfile();
        return {'success': true};
      }
      
      // Solo en caso de error 401 real de autenticación (no un error de negocio),
      // dejamos que el ApiClient maneje el logout o devolvemos el error.
      // El ApiClient ya maneja el 401 expirado.
      return {
        'success': false, 
        'statusCode': response.statusCode,
        'message': _parseError(response.body)
      };
    } catch(e) {
      return {'success': false, 'message': 'Error al actualizar perfil: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePerfilProveedor(Map<String, dynamic> data) async {
    try {
      // Remover nulos
      final cleanedData = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => value == null || key.isEmpty);

      final response = await _apiClient.patchRequest('/perfil/proveedor', cleanedData);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchAndStoreProfile();
        return {'success': true};
      }
      
      return {
        'success': false, 
        'statusCode': response.statusCode,
        'message': _parseError(response.body)
      };
    } catch(e) {
      return {'success': false, 'message': 'Error al actualizar perfil: $e'};
    }
  }

  // Enviar Solicitud Proveedor (Multipart)
  Future<Map<String, dynamic>> enviarSolicitudProveedor({
    required String descripcion, 
    required String experiencia, 
    required List<String> filePaths
  }) async {
    try {
      final uri = Uri.parse('${EnvironmentConfig.apiBaseUrl}/solicitud/Enviar_Solicitud');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['descripcionPerfil'] = descripcion;
      request.fields['anosExperiencia'] = experiencia;

      for (var path in filePaths) {
        request.files.add(await http.MultipartFile.fromPath('documentos', path));
      }

      final streamedResponse = await _apiClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': _parseError(response.body)};
    } catch (e) {
      return {'success': false, 'message': 'Error al enviar solicitud: $e'};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'role');
    _isLoggedIn = false;
    _currentRole = null;
    currentUserProfile = null;
  }

  String _parseError(String body) {
    if (body.isEmpty) return 'Error desconocido en el servidor';
    
    try {
      final decoded = jsonDecode(body);
      
      // Caso 1: Estructura { "message": "..." } o { "error": "..." }
      if (decoded is Map) {
        if (decoded.containsKey('message')) return decoded['message'].toString();
        if (decoded.containsKey('error')) return decoded['error'].toString();
        if (decoded.containsKey('title')) return decoded['title'].toString();
        
        // Caso 2: Estructura { "errors": { "field": ["err1", "err2"] } } (.NET ValidationErrors)
        if (decoded.containsKey('errors') && decoded['errors'] is Map) {
          final Map<String, dynamic> errors = decoded['errors'];
          if (errors.isNotEmpty) {
            final firstErrorEntry = errors.values.first;
            if (firstErrorEntry is List && firstErrorEntry.isNotEmpty) {
              return firstErrorEntry.first.toString();
            }
            return firstErrorEntry.toString();
          }
        }
      }
      
      // Caso 3: Es un string simple
      if (decoded is String) return decoded;
      
      return 'Error del servidor (formato no reconocido)';
    } catch (_) {
      // Si no es JSON, devolvemos el body tal cual si no es muy largo, o un genérico
      if (body.length < 100) return body;
      return 'Error desconocido en el servidor';
    }
  }
}
