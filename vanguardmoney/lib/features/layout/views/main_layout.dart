import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/layout_viewmodel.dart';
import 'tabs/home_tab_page.dart';
import 'tabs/planes_tab_page.dart';
import 'tabs/transacciones_tab_page.dart';
import 'tabs/reportes_tab_page.dart';
import 'tabs/analysis_tab_page.dart';
import 'widgets/profile_drawer.dart';
import '../../../core/constants/app_strings.dart';

// LAYOUT PRINCIPAL - Solo contiene la estructura de navegación
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(layoutViewModelProvider);

    // Lista de páginas para IndexedStack - PATRÓN CONSISTENTE DE TABS
    // Reordenadas para poner Análisis IA en el centro (posición 2)
    final pages = [
      const HomeTabPage(), // ✅ REAL: Tab que llama a HomeView
      const PlanesTabPage(), // ❌ PLACEHOLDER: Tab con contenido temporal
      const AnalysisTabPage(), // ✅ REAL: Tab de análisis IA - CENTRO
      const TransaccionesTabPage(), // ✅ REAL: Tab que llama a TransaccionesView
      const ReportesTabPage(), // ❌ PLACEHOLDER: Tab con contenido temporal
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTab.title),
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
      bottomNavigationBar: _buildCustomBottomNavigationBar(
        context,
        ref,
        currentTab.tabIndex,
      ),
      floatingActionButton: _buildAICenterButton(
        context,
        ref,
        currentTab.tabIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Botón flotante central para Análisis IA - Diseño innovador
  Widget _buildAICenterButton(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    final isAISelected =
        currentIndex == 2; // Análisis IA ahora está en posición 2

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isAISelected ? 60 : 56,
      width: isAISelected ? 60 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAISelected
              ? [
                  const Color(0xFF6A11CB), // Púrpura vibrante
                  const Color(0xFF2575FC), // Azul eléctrico
                ]
              : [
                  const Color(0xFF667eea), // Azul suave
                  const Color(0xFFf093fb), // Rosa suave
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isAISelected
                ? const Color(0xFF6A11CB).withOpacity(0.4)
                : const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: isAISelected ? 15 : 10,
            offset: const Offset(0, 5),
            spreadRadius: isAISelected ? 2 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(layoutViewModelProvider.notifier).navigateToIndex(2);
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_alt,
                    size: isAISelected ? 28 : 24,
                    color: Colors.white,
                  ),
                  if (isAISelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.navAnalysisIA,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Barra de navegación personalizada sin el botón central
  Widget _buildCustomBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                0,
                Icons.home,
                AppStrings.navHome,
                currentIndex,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                1,
                Icons.timeline,
                AppStrings.navPlanes,
                currentIndex,
              ),
            ),
            const SizedBox(width: 40), // Espacio para el FAB central
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                3,
                Icons.add_circle_outline,
                AppStrings.navTransactions,
                currentIndex,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                4,
                Icons.bar_chart,
                AppStrings.navReports,
                currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget individual para cada item de navegación - Diseño mejorado sin overflow
  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(layoutViewModelProvider.notifier).navigateToIndex(index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                    size: isSelected ? 22 : 20,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
