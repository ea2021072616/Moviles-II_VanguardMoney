import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/financial_plans_viewmodel.dart';
import '../models/financial_plan_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../transactions/views/gestionar_categorias_view.dart';
import '../../transactions/models/categoria_model.dart';
import '../../auth/providers/auth_providers.dart';
import 'widgets/create_plan_dialog.dart';
import 'widgets/plan_card.dart';
import 'widgets/category_budget_card.dart';

class FinancialPlansPage extends ConsumerStatefulWidget {
  const FinancialPlansPage({super.key});

  @override
  ConsumerState<FinancialPlansPage> createState() => _FinancialPlansPageState();
}

class _FinancialPlansPageState extends ConsumerState<FinancialPlansPage> {
  bool _showCurrentPlan = true;

  @override
  void initState() {
    super.initState();
    // Cargar planes al iniciar
    Future.microtask(
      () => ref
          .read(financialPlansViewModelProvider.notifier)
          .loadFinancialPlans(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financialPlansState = ref.watch(financialPlansViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: financialPlansState.when(
        data: (state) => _buildContent(context, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Planes Financieros'),
      backgroundColor: AppColors.blueClassic,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            switch (value) {
              case 'toggle_view':
                setState(() {
                  _showCurrentPlan = !_showCurrentPlan;
                });
                break;
              case 'categories':
                _navigateToCategories(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_view',
              child: Row(
                children: [
                  Icon(
                    _showCurrentPlan ? Icons.list : Icons.calendar_today,
                    color: AppColors.blackGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showCurrentPlan
                        ? 'Ver todos los planes'
                        : 'Ver plan actual',
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'categories',
              child: Row(
                children: [
                  Icon(Icons.category, color: AppColors.blackGrey),
                  SizedBox(width: 8),
                  Text('Gestionar Categorías'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FinancialPlansState state) {
    switch (state) {
      case FinancialPlansInitial():
        return _buildEmptyState(context);
      case FinancialPlansLoading():
        return const Center(child: CircularProgressIndicator());
      case FinancialPlansLoaded():
        return _showCurrentPlan
            ? _buildCurrentPlanView(context, state)
            : _buildAllPlansView(context, state);
      case FinancialPlansError():
        return _buildErrorState(context, state.message);
    }
  }

  Widget _buildCurrentPlanView(
    BuildContext context,
    FinancialPlansLoaded state,
  ) {
    final currentPlan = state.currentPlan;

    if (currentPlan == null) {
      return _buildNoCurrentPlanState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen del plan
          _buildPlanSummaryCard(context, currentPlan),

          const SizedBox(height: 20),

          // Botón para ver categorías
          _buildSectionButton(
            context,
            title: 'Ver Categorías',
            icon: Icons.category_outlined,
            color: AppColors.yellowPastel,
            onPressed: () => _navigateToCategories(context),
          ),

          const SizedBox(height: 20),

          // Lista de categorías con presupuesto
          _buildCategoriesList(context, currentPlan),

          const SizedBox(height: 20),

          // Gráfico de gastos por mes (placeholder)
          _buildMonthlyChart(context, currentPlan),
        ],
      ),
    );
  }

  Widget _buildAllPlansView(BuildContext context, FinancialPlansLoaded state) {
    final plans = state.plans;

    if (plans.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlanCard(
            plan: plan,
            onTap: () => _showPlanDetails(context, plan),
            onEdit: () => _editPlan(context, plan),
            onDelete: () => _deletePlan(context, plan),
          ),
        );
      },
    );
  }

  Widget _buildPlanSummaryCard(BuildContext context, FinancialPlanModel plan) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.blueClassic,
              AppColors.blueClassic.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.planName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${plan.monthName} ${plan.year}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progreso general
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gasto Actual',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'S/ ${plan.totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${plan.totalUsagePercentage.toInt()}%',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Límite: S/ ${plan.totalBudget.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            // Barra de progreso
            LinearProgressIndicator(
              value: plan.totalUsagePercentage / 100,
              backgroundColor: AppColors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                plan.isOverBudget ? AppColors.redCoral : AppColors.greenJade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.white),
        label: Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, FinancialPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Presupuesto por Categoría',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackGrey,
          ),
        ),
        const SizedBox(height: 12),

        ...plan.categoryBudgets.map(
          (categoryBudget) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CategoryBudgetCard(
              categoryBudget: categoryBudget,
              onUpdateSpent: (newAmount) => _updateCategorySpent(
                context,
                plan.id,
                categoryBudget.categoryId,
                newAmount,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(BuildContext context, FinancialPlanModel plan) {
    // Por ahora, placeholder para el gráfico
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso Mensual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.blackGrey,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: AppColors.greyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gráfico próximamente',
                      style: TextStyle(
                        color: AppColors.greyMedium,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(100 - plan.totalUsagePercentage).toStringAsFixed(1)}% menos que el mes pasado',
                      style: TextStyle(
                        color: AppColors.greyMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCurrentPlanState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.blueClassic.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 64,
                color: AppColors.blueClassic,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No tienes plan para este mes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackGrey,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Crea tu primer plan financiero para ${DateTime.now().month == 1
                  ? 'Enero'
                  : DateTime.now().month == 2
                  ? 'Febrero'
                  : DateTime.now().month == 3
                  ? 'Marzo'
                  : DateTime.now().month == 4
                  ? 'Abril'
                  : DateTime.now().month == 5
                  ? 'Mayo'
                  : DateTime.now().month == 6
                  ? 'Junio'
                  : DateTime.now().month == 7
                  ? 'Julio'
                  : DateTime.now().month == 8
                  ? 'Agosto'
                  : DateTime.now().month == 9
                  ? 'Septiembre'
                  : DateTime.now().month == 10
                  ? 'Octubre'
                  : DateTime.now().month == 11
                  ? 'Noviembre'
                  : 'Diciembre'} y toma el control de tus gastos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.greyMedium),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () => _showCreatePlanDialog(context),
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'Crear Plan del Mes',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueClassic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.greenJade.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings,
                size: 64,
                color: AppColors.greenJade,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '¡Comienza a planificar!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.blackGrey,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Crea tu primer plan financiero y organiza tus gastos de manera inteligente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.greyMedium),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () => _showCreatePlanDialog(context),
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'Crear Primer Plan',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenJade,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.redCoral,
            ),

            const SizedBox(height: 16),

            const Text(
              'Error al cargar planes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackGrey,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () => ref
                  .read(financialPlansViewModelProvider.notifier)
                  .loadFinancialPlans(),
              icon: const Icon(Icons.refresh, color: AppColors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueClassic,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showCreatePlanDialog(context),
      backgroundColor: AppColors.blueClassic,
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePlanDialog(
        onPlanCreated: () {
          ref
              .read(financialPlansViewModelProvider.notifier)
              .loadFinancialPlans();
        },
      ),
    );
  }

  void _navigateToCategories(BuildContext context) {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GestionarCategoriasView(
            idUsuario: user.id,
            tipo: TipoCategoria.egreso,
          ),
        ),
      );
    }
  }

  void _showPlanDetails(BuildContext context, FinancialPlanModel plan) {
    // TODO: Implementar página de detalles del plan
  }

  void _editPlan(BuildContext context, FinancialPlanModel plan) {
    // TODO: Implementar edición del plan
  }

  void _deletePlan(BuildContext context, FinancialPlanModel plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Plan'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el plan "${plan.planName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(financialPlansViewModelProvider.notifier)
                  .deleteFinancialPlan(plan.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan eliminado exitosamente')),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.redCoral),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategorySpent(
    BuildContext context,
    String planId,
    String categoryId,
    double newAmount,
  ) async {
    final success = await ref
        .read(financialPlansViewModelProvider.notifier)
        .updateCategorySpent(
          planId: planId,
          categoryId: categoryId,
          newSpentAmount: newAmount,
        );

    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto actualizado')));
    }
  }
}
