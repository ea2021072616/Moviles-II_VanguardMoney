import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import '../model/auth_request.dart';
import '../model/user.dart';

// Estado de autenticación
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AuthState clearError() {
    return copyWith(error: null);
  }
}

// Notificador de estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkStoredSession();
  }

  /// Verificar si hay una sesión guardada al inicializar
  Future<void> _checkStoredSession() async {
    state = state.copyWith(isLoading: true);

    try {
      final hasSession = await _authService.hasStoredSession();
      if (hasSession) {
        final user = await _authService.getUser();
        final isValid = await _authService.isAuthenticated();

        if (isValid && user != null) {
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
          );
        } else {
          // Sesión inválida, limpiar
          await _authService.logout();
          state = state.copyWith(isLoading: false);
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al verificar sesión: $e',
      );
    }
  }

  /// Iniciar sesión
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      print(
        '🎯 AuthProvider - Login response: success=${response.success}, user=${response.user?.email}',
      );

      if (response.success && response.user != null && response.token != null) {
        print('✅ AuthProvider - Login exitoso, actualizando estado...');
        state = state.copyWith(
          isAuthenticated: true,
          user: response.user,
          isLoading: false,
          error: null, // Limpiar cualquier error previo
        );
        return true;
      } else {
        print('❌ AuthProvider - Login falló: ${response.message}');
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Error al iniciar sesión',
        );
        return false;
      }
    } catch (e) {
      print('💥 AuthProvider - Exception: $e');
      state = state.copyWith(isLoading: false, error: 'Error de conexión: $e');
      return false;
    }
  }

  /// Registrar usuario
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      final response = await _authService.register(request);

      if (response.success && response.user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.user,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Error al registrar usuario',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error de conexión: $e');
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  /// Limpiar errores
  void clearError() {
    state = state.clearError();
  }
}

// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider global de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
