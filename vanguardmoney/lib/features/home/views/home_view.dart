import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/constants/app_routes.dart';
import '../viewmodels/home_viewmodel.dart';

// Provider para el HomeViewModel
final homeViewModelProvider = ChangeNotifierProvider.autoDispose<HomeViewModel>((ref) {
  final viewModel = HomeViewModel();
  // Cargar datos automáticamente
  viewModel.cargarDatosHome();
  return viewModel;
});

// VISTA ESPECÍFICA DEL HOME - Dashboard principal
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider).cargarDatosHome();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cada vez que se vuelve a esta pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeViewModelProvider).cargarDatosHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final homeViewModel = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => homeViewModel.refrescar(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              _buildGreetingCard(
                context,
                currentUser?.preferredName ?? 'Usuario',
              ),
              const SizedBox(height: 16),

              // Mostrar error si existe
              if (homeViewModel.error != null)
                _buildErrorCard(context, homeViewModel.error!),

              // Resumen de saldo
              _buildBalanceCard(context, homeViewModel),
              const SizedBox(height: 16),

              // Últimas transacciones
              _buildRecentTransactions(context, homeViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $userName!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido a VanguardMoney',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'S/ ${_formatCurrency(viewModel.balance)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: viewModel.balance >= 0 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    context,
                    'Ingresos',
                    '+ S/ ${_formatCurrency(viewModel.totalIngresos)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceItem(
                    context,
                    'Egresos',
                    '- S/ ${_formatCurrency(viewModel.totalGastos)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, HomeViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transacciones Recientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push(AppRoutes.transactions);
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Mostrar loading
            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            // Mostrar transacciones o mensaje vacío
            else if (viewModel.transaccionesRecientes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay transacciones recientes',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Mostrar las transacciones
              ...viewModel.transaccionesRecientes.map((transaccion) {
                final esIngreso = transaccion.tipo == 'ingreso';
                final color = esIngreso ? Colors.green : Colors.red;
                final signo = esIngreso ? '+' : '-';
                
                return _buildTransactionItem(
                  context,
                  transaccion.categoria,
                  '$signo S/ ${_formatCurrency(transaccion.monto)}',
                  transaccion.icono,
                  color,
                  viewModel.obtenerTextoRelativoFecha(transaccion.fecha),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
