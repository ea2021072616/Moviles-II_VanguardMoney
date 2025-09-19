import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_model.dart';
import '../service/auth_repository.dart';

/// Provider del AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider que escucha los cambios de estado de autenticación de Firebase
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Estados de autenticación para el ViewModel
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError(this.message, {this.code});
}

/// ViewModel para manejo de autenticación usando AsyncNotifier
class AuthViewModel extends AsyncNotifier<AuthState> {
  late AuthRepository _authRepository;

  @override
  Future<AuthState> build() async {
    _authRepository = ref.read(authRepositoryProvider);

    // Escuchar cambios en el estado de autenticación
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AsyncValue.data(AuthAuthenticated(user));
          } else {
            state = const AsyncValue.data(AuthUnauthenticated());
          }
        },
        loading: () => state = const AsyncValue.data(AuthLoading()),
        error: (error, stack) => state = AsyncValue.data(
          AuthError('Error en el estado de autenticación: $error'),
        ),
      );
    });

    // Estado inicial basado en el usuario actual
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      return AuthAuthenticated(currentUser);
    } else {
      return const AuthUnauthenticated();
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(AuthAuthenticated(user));
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message, code: e.code));
    } catch (e) {
      state = AsyncValue.data(AuthError('Error inesperado: $e'));
    }
  }

  /// Registrar usuario con email y contraseña
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String currency,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.registerWithEmail(
        email: email,
        password: password,
        username: username,
        currency: currency,
      );
      state = AsyncValue.data(AuthAuthenticated(user));
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message, code: e.code));
    } catch (e) {
      state = AsyncValue.data(AuthError('Error inesperado: $e'));
    }
  }

  /// Iniciar sesión con Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(AuthAuthenticated(user));
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message, code: e.code));
    } catch (e) {
      state = AsyncValue.data(AuthError('Error inesperado: $e'));
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(AuthUnauthenticated());
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message, code: e.code));
    } catch (e) {
      state = AsyncValue.data(AuthError('Error inesperado: $e'));
    }
  }

  /// Enviar email para resetear contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthError(e.message, code: e.code));
    }
  }

  /// Limpiar errores
  void clearError() {
    state.whenData((data) {
      if (data is AuthError) {
        state = const AsyncValue.data(AuthUnauthenticated());
      }
    });
  }

  /// Getters de conveniencia
  bool get isAuthenticated {
    return state.value is AuthAuthenticated;
  }

  bool get isLoading {
    return state.isLoading || state.value is AuthLoading;
  }

  UserModel? get currentUser {
    final authState = state.value;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  String? get errorMessage {
    final authState = state.value;
    if (authState is AuthError) {
      return authState.message;
    }
    return null;
  }
}

/// Provider principal del AuthViewModel
final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, AuthState>(
  () {
    return AuthViewModel();
  },
);

/// Provider de conveniencia para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider).value;
  return authState is AuthAuthenticated;
});

/// Provider de conveniencia para obtener el usuario actual
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authViewModelProvider).value;
  if (authState is AuthAuthenticated) {
    return authState.user;
  }
  return null;
});
