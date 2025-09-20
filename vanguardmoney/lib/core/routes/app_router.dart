import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/edit_profile_page.dart';
import '../../features/layout/views/main_layout.dart';
import '../../features/analysis/views/ai_analysis_page.dart';
import '../widgets/splash_screen.dart';

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
        builder: (context, state) => const MainLayout(),
      ),

      // Ruta para editar perfil
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),

      // Ruta para análisis IA
      GoRoute(
        path: '/analysis',
        name: 'analysis',
        builder: (context, state) => const AiAnalysisPage(),
      ),

      // Ruta de fallback
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
    ],
  );
});
