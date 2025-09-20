import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // 🎨 NUEVO SISTEMA DE THEME CON BRANDING VANGUARDMONEY
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Por ahora solo tema claro
      // Configuración adicional
      locale: const Locale('es', 'ES'), // Español
    );
  }
}
