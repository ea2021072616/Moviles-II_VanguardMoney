import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/auth_request.dart';
import '../model/auth_response.dart';
import '../model/user.dart';

class AuthService {
  // URL base del microservicio - Cambia esto por tu URL real
  static const String _baseUrl = 'http://10.0.2.2:3000';

  // MODO DEMO - Cambia a false cuando tengas el microservicio
  static const bool _demoMode = false;

  // Storage seguro para tokens
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys para storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  /// Registrar un nuevo usuario
  Future<AuthResponse> register(RegisterRequest request) async {
    // MODO DEMO - Para probar sin microservicio
    if (_demoMode) {
      print('🎭 MODO DEMO - Simulando registro...');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay de red

      final demoUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: request.email,
        firstName: request.firstName,
        lastName: request.lastName,
      );

      await _saveToken('demo_token_${DateTime.now().millisecondsSinceEpoch}');
      await _saveUser(demoUser);

      return AuthResponse.success(
        message: 'Registro exitoso',
        token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        user: demoUser,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registro exitoso - procesando respuesta...');

        // El microservicio devuelve: { success, message, data: { user, token } }
        if (data['success'] == true && data['data'] != null) {
          final dataObj = data['data'];
          if (dataObj['token'] != null && dataObj['user'] != null) {
            await _saveToken(dataObj['token']);
            final user = User.fromJson(dataObj['user']);
            await _saveUser(user);

            return AuthResponse.success(
              message: data['message'] ?? 'Registro exitoso',
              token: dataObj['token'],
              user: user,
            );
          }
        }

        print('⚠️ Registro exitoso pero estructura inesperada');
        return AuthResponse.error(
          'Respuesta del servidor con estructura inesperada',
        );
      } else {
        return AuthResponse.error(
          data['message'] ?? 'Error en el registro',
          errors: data['errors'],
        );
      }
    } catch (e) {
      return AuthResponse.error('Error de conexión: $e');
    }
  }

  /// Iniciar sesión
  Future<AuthResponse> login(LoginRequest request) async {
    // MODO DEMO - Para probar sin microservicio
    if (_demoMode) {
      print('🎭 MODO DEMO - Simulando login...');
      await Future.delayed(const Duration(seconds: 1)); // Simular delay de red

      // Credenciales de prueba
      if (request.email == 'demo@test.com' && request.password == 'Demo123!') {
        final demoUser = User(
          id: '1',
          email: 'demo@test.com',
          firstName: 'Demo',
          lastName: 'Usuario',
        );

        await _saveToken('demo_token_123');
        await _saveUser(demoUser);

        return AuthResponse.success(
          message: 'Inicio de sesión exitoso',
          token: 'demo_token_123',
          user: demoUser,
        );
      } else {
        return AuthResponse.error(
          'Credenciales incorrectas. Usa: demo@test.com / Demo123!',
        );
      }
    }

    try {
      print('🔍 Intentando login con: ${request.email}');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Login exitoso - procesando respuesta...');

        // El microservicio devuelve: { success, message, data: { user, token } }
        if (data['success'] == true && data['data'] != null) {
          final dataObj = data['data'];
          if (dataObj['token'] != null && dataObj['user'] != null) {
            await _saveToken(dataObj['token']);
            final user = User.fromJson(dataObj['user']);
            await _saveUser(user);

            return AuthResponse.success(
              message: data['message'] ?? 'Inicio de sesión exitoso',
              token: dataObj['token'],
              user: user,
            );
          }
        }

        print('⚠️ Respuesta exitosa pero estructura inesperada');
        print('📄 Data structure: $data');
        return AuthResponse.error(
          'Respuesta del servidor con estructura inesperada',
        );
      } else {
        print('❌ Error en login: ${response.statusCode}');
        return AuthResponse.error(
          data['message'] ?? 'Credenciales incorrectas',
          errors: data['errors'],
        );
      }
    } catch (e) {
      print('💥 Exception en login: $e');
      return AuthResponse.error('Error de conexión: $e');
    }
  }

  /// Verificar si hay un token válido
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: _headersWithAuth(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtener perfil del usuario
  Future<AuthResponse> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse.error('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: _headersWithAuth(token),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse.error(data['message'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      return AuthResponse.error('Error de conexión: $e');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Obtener token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Obtener usuario guardado
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Guardar token de forma segura
  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Guardar usuario de forma segura
  Future<void> _saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Verificar si el usuario está logueado localmente
  Future<bool> hasStoredSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }
}
