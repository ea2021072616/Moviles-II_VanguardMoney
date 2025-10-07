import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/edit_profile_page.dart';
import '../../features/layout/views/main_layout.dart';
import '../../features/analysis/views/ai_analysis_page.dart';
import '../../features/Vertodo/views/ver_transacciones_view.dart';
import '../../features/notifications/views/notifications_page.dart';
import '../widgets/splash_screen.dart';
import '../constants/app_routes.dart';

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
        path: '/profile/edit',
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),

      // Ruta para análisis IA
      GoRoute(
        path: AppRoutes.aiAnalysis,
        name: 'analysis',
        builder: (context, state) => const AiAnalysisPage(),
      ),

      // Ruta para ver todas las transacciones
      GoRoute(
        path: AppRoutes.transactions,
        name: 'transactions',
        builder: (context, state) => const VerTransaccionesView(),
      ),

      // Ruta para notificaciones
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Ruta de fallback
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
    ],
  );
});
