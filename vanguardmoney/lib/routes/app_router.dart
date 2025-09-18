import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/view/login_page.dart';
import '../features/home/view/home_page.dart';
import '../core/widgets/splash_screen.dart';

// Router provider simplificado
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen (pantalla inicial)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

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
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
    ],
  );
});
