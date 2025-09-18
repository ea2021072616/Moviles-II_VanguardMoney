import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/view/login_page.dart';
import '../features/home/view/home_page.dart';
import '../features/auth/view_model/auth_provider.dart';

// Router provider que se reconstruye cuando cambia el estado de auth
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    routes: [
      // Rutas de autenticación
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Rutas principales (protegidas)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Ruta de fallback
      GoRoute(
        path: '/',
        redirect: (context, state) {
          return authState.isAuthenticated ? '/home' : '/login';
        },
      ),
    ],

    // Redirección global basada en autenticación
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      final isLoggingIn = state.fullPath == '/login';

      // Si no está autenticado y no está en login, redirigir a login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Si está autenticado y está en login, redirigir a home
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      // No redirigir
      return null;
    },
  );
});
