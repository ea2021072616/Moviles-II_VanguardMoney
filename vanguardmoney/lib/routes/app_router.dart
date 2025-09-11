import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/register_page.dart';
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
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
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
      final isLogin = state.fullPath == '/login';
      final isRegister = state.fullPath == '/register';

      // Si no está autenticado y no está en login ni registro, redirigir a login
      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/login';
      }

      // Si está autenticado y está en login o registro, redirigir a home
      if (isAuthenticated && (isLogin || isRegister)) {
        return '/home';
      }

      // No redirigir
      return null;
    },
  );
});
