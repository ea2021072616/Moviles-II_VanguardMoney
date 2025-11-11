import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../models/dashboard_stats_model.dart';
import 'dart:math' as math;

// Provider para el DashboardViewModel
final dashboardViewModelProvider =
    ChangeNotifierProvider.autoDispose<DashboardViewModel>(
  (ref) {
    final viewModel = DashboardViewModel();
    viewModel.loadDashboardData();
    return viewModel;
  },
);

/// Vista principal del Dashboard Financiero
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.error != null
                ? _buildErrorState(context, viewModel.error!)
                : viewModel.dashboardStats == null
                    ? _buildEmptyState(context)
                    : _buildDashboardContent(context, viewModel),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(dashboardViewModelProvider).loadDashboardData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Registra transacciones para ver tu dashboard',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardViewModel viewModel,
  ) {
    final stats = viewModel.dashboardStats!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de mes
          _buildMonthSelector(context, viewModel),
          const SizedBox(height: 16),

          // Resumen general del mes
          _buildMonthlySummary(context, stats.monthlyStats),
          const SizedBox(height: 24),

          // Gráfico de distribución de gastos
          if (stats.gastosPorCategoria.isNotEmpty) ...[
            _buildSectionTitle(context, 'Distribución de Gastos'),
            const SizedBox(height: 12),
            _buildExpensesChart(context, stats),
            const SizedBox(height: 24),
          ],

          // Lista de categorías de gastos
          if (stats.gastosPorCategoria.isNotEmpty) ...[
            _buildSectionTitle(context, 'Gastos por Categoría'),
            const SizedBox(height: 12),
            _buildCategoryList(context, stats.gastosPorCategoria, stats.monthlyStats.totalGastos),
            const SizedBox(height: 24),
          ],

          // Estado de planes financieros
          if (stats.planesActivos.isNotEmpty) ...[
            _buildSectionTitle(context, 'Planes Financieros'),
            const SizedBox(height: 12),
            _buildFinancialPlansList(context, stats.planesActivos),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: viewModel.previousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${viewModel.getMonthName(viewModel.selectedMonth)} ${viewModel.selectedYear}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              onPressed: viewModel.nextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, MonthlyStats stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance del Mes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Icon(
                  stats.isPositive ? Icons.trending_up : Icons.trending_down,
                  color: stats.isPositive ? Colors.green : Colors.red,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'S/ ${_formatCurrency(stats.balance)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stats.isPositive ? Colors.green[700] : Colors.red[700],
                  ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),

            // Ingresos y Gastos
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Ingresos',
                    stats.totalIngresos,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Gastos',
                    stats.totalGastos,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(
                    context,
                    '${stats.cantidadTransacciones}',
                    'Transacciones',
                    Icons.receipt_long,
                  ),
                  _buildInfoChip(
                    context,
                    '${stats.savingsPercentage.toStringAsFixed(1)}%',
                    'Ahorro',
                    Icons.savings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'S/ ${_formatCurrency(amount)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpensesChart(BuildContext context, DashboardStatsModel stats) {
    final totalGastos = stats.monthlyStats.totalGastos;
    if (totalGastos <= 0) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: PieChartPainter(
                  categories: stats.gastosPorCategoria,
                  total: totalGastos,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      Text(
                        'S/ ${_formatCurrency(totalGastos)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: stats.gastosPorCategoria.take(5).map((cat) {
                final color = _getCategoryColor(
                  stats.gastosPorCategoria.indexOf(cat),
                );
                return _buildLegendItem(context, cat.categoryName, color);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<CategoryStats> categories,
    double total,
  ) {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final percentage = category.calculatePercentage(total);
          final color = _getCategoryColor(index);

          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(category.categoryName),
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              category.categoryName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${category.transactionCount} transacciones'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${_formatCurrency(category.amount)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinancialPlansList(
    BuildContext context,
    List<PlanSummary> plans,
  ) {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
        ),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final statusColor = _getPlanStatusColor(plan.status);

          return ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPlanStatusIcon(plan.status),
                color: statusColor,
                size: 20,
              ),
            ),
            title: Text(
              plan.planName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${plan.categoriesCount} categorías'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: plan.usagePercentage / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Información detallada
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPlanDetail(
                          context,
                          'Presupuesto',
                          'S/ ${_formatCurrency(plan.totalBudget)}',
                          Colors.blue,
                        ),
                        _buildPlanDetail(
                          context,
                          'Gastado',
                          'S/ ${_formatCurrency(plan.totalSpent)}',
                          statusColor,
                        ),
                        _buildPlanDetail(
                          context,
                          'Restante',
                          'S/ ${_formatCurrency(plan.remainingAmount)}',
                          Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Porcentaje
                    Text(
                      'Usado: ${plan.usagePercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanDetail(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.amber[600]!,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('alimento') || name.contains('comida')) {
      return Icons.restaurant;
    } else if (name.contains('transporte')) {
      return Icons.directions_car;
    } else if (name.contains('salud')) {
      return Icons.medical_services;
    } else if (name.contains('educación') || name.contains('educacion')) {
      return Icons.school;
    } else if (name.contains('entretenimiento')) {
      return Icons.movie;
    } else if (name.contains('vivienda')) {
      return Icons.home;
    } else if (name.contains('ropa')) {
      return Icons.checkroom;
    }
    return Icons.category;
  }

  Color _getPlanStatusColor(PlanStatus status) {
    switch (status) {
      case PlanStatus.healthy:
        return Colors.green;
      case PlanStatus.caution:
        return Colors.orange;
      case PlanStatus.warning:
        return Colors.deepOrange;
      case PlanStatus.exceeded:
        return Colors.red;
    }
  }

  IconData _getPlanStatusIcon(PlanStatus status) {
    switch (status) {
      case PlanStatus.healthy:
        return Icons.check_circle;
      case PlanStatus.caution:
        return Icons.warning_amber;
      case PlanStatus.warning:
        return Icons.error_outline;
      case PlanStatus.exceeded:
        return Icons.dangerous;
    }
  }
}

/// Custom Painter para el gráfico circular (pie chart)
class PieChartPainter extends CustomPainter {
  final List<CategoryStats> categories;
  final double total;

  PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    double startAngle = -math.pi / 2;

    final colors = [
      Colors.blue[600]!,
      Colors.red[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.amber[600]!,
    ];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final sweepAngle = (category.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Dibujar círculo blanco en el centro para efecto "donut"
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
