import 'package:flutter_riverpod/flutter_riverpod.dart';

// Estado de autenticación simple
class AuthState {
  final bool isAuthenticated;
  final String? userName;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.userName,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notificador de estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    // Simular autenticación (reemplaza con tu lógica real)
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      isAuthenticated: true,
      userName: email,
      isLoading: false,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

// Provider global de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
