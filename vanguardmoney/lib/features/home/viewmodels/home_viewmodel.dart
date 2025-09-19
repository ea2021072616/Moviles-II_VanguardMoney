import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estados posibles para la navegación en el Home
enum HomeNavigationTab {
  home(0, 'Inicio'),
  financialPlans(1, 'Planes'),
  transactions(2, 'Transacciones'),
  reports(3, 'Reportes'),
  analysis(4, 'Análisis IA');

  const HomeNavigationTab(this.tabIndex, this.title);
  final int tabIndex;
  final String title;
}

/// ViewModel para manejar el estado del Home
class HomeViewModel extends StateNotifier<HomeNavigationTab> {
  HomeViewModel() : super(HomeNavigationTab.home);

  /// Cambiar a un tab específico
  void navigateToTab(HomeNavigationTab tab) {
    state = tab;
  }

  /// Cambiar por índice
  void navigateToIndex(int index) {
    final tab = HomeNavigationTab.values.firstWhere(
      (tab) => tab.tabIndex == index,
      orElse: () => HomeNavigationTab.home,
    );
    state = tab;
  }

  /// Getter para verificar si el FAB debería mostrarse
  bool get shouldShowFab {
    return true; // Mostrar el FAB en todos los tabs
  }

  /// Getter para obtener el título del AppBar
  String get appBarTitle {
    return state.title;
  }
}

/// Provider para el HomeViewModel
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeNavigationTab>(
      (ref) => HomeViewModel(),
    );

/// Provider de conveniencia para el índice actual
final currentTabIndexProvider = Provider<int>((ref) {
  return ref.watch(homeViewModelProvider).tabIndex;
});

/// Provider de conveniencia para mostrar FAB
final showFabProvider = Provider<bool>((ref) {
  final homeViewModel = ref.read(homeViewModelProvider.notifier);
  return homeViewModel.shouldShowFab;
});

/// Provider de conveniencia para el título del AppBar
final appBarTitleProvider = Provider<String>((ref) {
  final homeViewModel = ref.read(homeViewModelProvider.notifier);
  return homeViewModel.appBarTitle;
});
