import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/Ver_transacciones_viewmodel.dart';
import '../../../core/theme/app_colors.dart';

class VerTransaccionesView extends StatefulWidget {
  const VerTransaccionesView({Key? key}) : super(key: key);

  @override
  State<VerTransaccionesView> createState() => _VerTransaccionesViewState();
}

class _VerTransaccionesViewState extends State<VerTransaccionesView> {
  late VerTransaccionesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VerTransaccionesViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    await _viewModel.cargarTransacciones();
  }

  // Método para formatear números como moneda
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Método para formatear fechas
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VerTransaccionesViewModel>(
      create: (_) => _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Transacciones',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          backgroundColor: AppColors.blueClassic,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh, color: AppColors.white),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: Consumer<VerTransaccionesViewModel>(
          builder: (context, viewModel, child) {
            return _buildTransaccionesList(viewModel);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refrescarDatos,
          backgroundColor: AppColors.blueClassic,
          child: const Icon(Icons.add, color: AppColors.white),
          tooltip: 'Agregar transacción',
        ),
      ),
    );
  }

  Widget _buildTransaccionesList(VerTransaccionesViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueClassic),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando transacciones...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyDark,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.redCoral,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar transacciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.redCoral,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                viewModel.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueClassic,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.transacciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus transacciones aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyDark,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      color: AppColors.blueClassic,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: viewModel.transacciones.length,
        itemBuilder: (context, index) {
          final transaccion = viewModel.transacciones[index];
          return _buildTransaccionCard(transaccion);
        },
      ),
    );
  }

  Widget _buildTransaccionCard(TransaccionItem transaccion) {
    final bool esIngreso = transaccion.tipo == 'ingreso';
    final Color colorPrincipal = esIngreso ? const Color(0xFF377CC8) : AppColors.redCoral;
    final IconData icono = esIngreso ? Icons.add_circle : Icons.remove_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorPrincipal.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorPrincipal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: colorPrincipal,
              size: 24,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaccion.categoria,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${esIngreso ? '+' : '-'}\$${_formatCurrency(transaccion.monto)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorPrincipal,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (transaccion.descripcion.isNotEmpty)
                Text(
                  transaccion.descripcion,
                  style: TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(transaccion.fecha),
                    style: TextStyle(
                      color: AppColors.greyDark,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorPrincipal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      esIngreso ? 'Ingreso' : 'Gasto',
                      style: TextStyle(
                        color: colorPrincipal,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refrescarDatos() async {
    await _viewModel.refrescar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
