import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/navigation_provider.dart';
import 'tabs/home_tab_page.dart';
import 'tabs/planes_tab_page.dart';
import 'tabs/registro_tab_page.dart';
import 'tabs/reportes_tab_page.dart';
import 'ai_analysis_page.dart';
import 'widgets/profile_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final showFab = ref.watch(showFabProvider);

    // Lista de páginas para IndexedStack
    final pages = [
      const HomeTabPage(),
      const PlanesTabPage(),
      const RegistroTabPage(),
      const ReportesTabPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(currentIndex)),
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
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        currentIndex,
      ),
      floatingActionButton: showFab
          ? _buildFloatingActionButton(context)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'VanguardMoney';
      case 1:
        return 'Planes Financieros';
      case 2:
        return 'Registro de Transacciones';
      case 3:
        return 'Reportes y Análisis';
      default:
        return 'VanguardMoney';
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _buildNavItem(context, ref, Icons.home, 'Home', 0, currentIndex),
            // Planes
            _buildNavItem(
              context,
              ref,
              Icons.timeline,
              'Planes',
              1,
              currentIndex,
            ),
            // Espacio para el FAB
            const SizedBox(width: 48),
            // Registro
            _buildNavItem(
              context,
              ref,
              Icons.add_circle_outline,
              'Registro',
              2,
              currentIndex,
            ),
            // Reportes
            _buildNavItem(
              context,
              ref,
              Icons.bar_chart,
              'Reportes',
              3,
              currentIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[600];

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(currentIndexProvider.notifier).state = index;

          // Ocultar FAB en la página de registro para evitar conflictos
          ref.read(showFabProvider.notifier).state = index != 2;
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: isSelected ? 24 : 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AiAnalysisPage()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const Icon(Icons.psychology, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
