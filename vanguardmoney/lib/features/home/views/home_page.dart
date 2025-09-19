import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/home_viewmodel.dart';
import 'tabs/home_tab_page.dart';
import 'tabs/planes_tab_page.dart';
import 'tabs/transacciones_tab_page.dart';
import 'tabs/reportes_tab_page.dart';
import 'tabs/analysis_tab_page.dart';
import 'widgets/profile_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    // Lista de páginas para IndexedStack - PATRÓN CONSISTENTE DE TABS
    final pages = [
      const HomeTabPage(), // ✅ REAL: Dashboard implementado
      const PlanesTabPage(), // ❌ PLACEHOLDER: Tab con contenido temporal
      const TransaccionesTabPage(), // ✅ REAL: Tab que llama a TransaccionesView
      const ReportesTabPage(), // ❌ PLACEHOLDER: Tab con contenido temporal
      const AnalysisTabPage(), // ✅ REAL: Tab de análisis IA
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(homeViewModel.appBarTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar búsqueda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Búsqueda próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      drawer: const ProfileDrawer(),
      body: IndexedStack(index: currentTab.tabIndex, children: pages),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        currentTab.tabIndex,
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(homeViewModelProvider.notifier).navigateToIndex(index);
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Planes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Transacciones',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'Análisis IA',
        ),
      ],
    );
  }
}
