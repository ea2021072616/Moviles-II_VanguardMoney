import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/layout_viewmodel.dart';
import 'tabs/home_tab_page.dart';
import 'tabs/planes_tab_page.dart';
import 'tabs/transacciones_tab_page.dart';
import 'tabs/reportes_tab_page.dart';
import 'tabs/analysis_tab_page.dart';
import 'widgets/profile_drawer.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

// LAYOUT PRINCIPAL - Solo contiene la estructura de navegación
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  // Colores específicos para cada tab
  Color _getTabColor(int index) {
    switch (index) {
      case 0: // Home - Inicio
        return AppColors.redCoral;
      case 1: // Planes
        return AppColors.greenJade;
      case 2: // Análisis IA
        return AppColors.blackGrey;
      case 3: // Transacciones
        return AppColors.pinkPastel;
      case 4: // Reportes
        return AppColors.yellowPastel;
      default:
        return AppColors.blueClassic;
    }
  }

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

  // Botón flotante central para Análisis IA - Diseño limpio con Gemini
  Widget _buildAICenterButton(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    final isAISelected = currentIndex == 2;
    final aiColor = _getTabColor(2); // Color específico para AI

    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: isAISelected ? aiColor : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isAISelected ? aiColor : AppColors.greyMedium,
          width: isAISelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAISelected
                ? aiColor.withOpacity(0.3)
                : AppColors.blackGrey.withOpacity(0.1),
            blurRadius: isAISelected ? 12 : 6,
            offset: const Offset(0, 3),
            spreadRadius: isAISelected ? 1 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(layoutViewModelProvider.notifier).navigateToIndex(2);
          },
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/gemini-color.svg',
              width: 32,
              height: 32,
              colorFilter: isAISelected
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null, // Mantener colores originales cuando no está seleccionado
            ),
          ),
        ),
      ),
    );
  }

  // Barra de navegación personalizada con diseño limpio
  Widget _buildCustomBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 0,
      color: AppColors.white,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.greyLight, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                0,
                Icons.home_outlined,
                Icons.home,
                AppStrings.navHome,
                currentIndex,
                _getTabColor(0), // Color específico para Home
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                1,
                Icons.timeline_outlined,
                Icons.timeline,
                AppStrings.navPlanes,
                currentIndex,
                _getTabColor(1), // Color específico para Planes
              ),
            ),
            const SizedBox(width: 64), // Espacio para el FAB central (Gemini)
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                3,
                Icons.add_circle_outline,
                Icons.add_circle,
                AppStrings.navTransactions,
                currentIndex,
                _getTabColor(3), // Color específico para Transacciones
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                ref,
                4,
                Icons.bar_chart_outlined,
                Icons.bar_chart,
                AppStrings.navReports,
                currentIndex,
                _getTabColor(4), // Color específico para Reportes
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget individual para cada item de navegación - Diseño limpio con línea superior
  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int currentIndex,
    Color tabColor, // Color específico para este tab
  ) {
    final isSelected = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(layoutViewModelProvider.notifier).navigateToIndex(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Línea superior de selección (como en la imagen)
              Container(
                height: 3,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected ? tabColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),
              // Icono
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? tabColor : AppColors.greyDark,
                size: 22,
              ),
              const SizedBox(height: 2),
              // Texto
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? tabColor : AppColors.greyDark,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
