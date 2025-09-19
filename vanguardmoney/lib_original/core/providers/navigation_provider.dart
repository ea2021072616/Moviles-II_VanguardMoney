import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el índice seleccionado en el BottomNavigationBar
final currentIndexProvider = StateProvider<int>((ref) => 0);

/// Provider para controlar la visibilidad del FAB
final showFabProvider = StateProvider<bool>((ref) => true);

/// Enum para las secciones de navegación
enum NavigationSection {
  home(0, 'Home'),
  planes(1, 'Planes'),
  registro(2, 'Registro'),
  reportes(3, 'Reportes');

  const NavigationSection(this.tabIndex, this.label);

  final int tabIndex;
  final String label;
}
