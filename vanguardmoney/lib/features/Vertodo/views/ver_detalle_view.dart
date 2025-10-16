import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/ver_detalle_viewmodel.dart';
import '../../edit_transactions/viewmodels/edit_transactions_viwmodel.dart';
import '../../edit_transactions/views/edit_transaction_view.dart';

class VerDetalleView extends StatefulWidget {
  final String transaccionId;
  final String tipo; // 'ingreso' o 'gasto'

  const VerDetalleView({
    Key? key,
    required this.transaccionId,
    required this.tipo,
  }) : super(key: key);

  @override
  State<VerDetalleView> createState() => _VerDetalleViewState();
}

class _VerDetalleViewState extends State<VerDetalleView> {
  bool _transaccionModificada = false; // Flag para saber si se editó o eliminó

  @override
  void initState() {
    super.initState();
    // Cargar los detalles cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerDetalleViewModel>().cargarDetalle(
        widget.transaccionId,
        widget.tipo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && _transaccionModificada) {
          // Notificar a la pantalla anterior que hubo cambios
          // El resultado ya se maneja en el pop automático
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Regresar con el estado de modificación
              Navigator.of(context).pop(_transaccionModificada);
            },
          ),
          title: const Text('Detalle de Transacción'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _navegarAEditar(context),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _mostrarDialogoEliminar(context),
              tooltip: 'Eliminar',
            ),
          ],
        ),
        body: Consumer<VerDetalleViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.cargarDetalle(
                          widget.transaccionId,
                          widget.tipo,
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final detalle = viewModel.detalleTransaccion;
            if (detalle == null) {
              return const Center(child: Text('No se encontró la transacción'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header con el tipo y monto
                  _buildHeader(context, viewModel, detalle),

                  const SizedBox(height: 16),

                  // Información general
                  _buildSeccionInformacion(detalle),

                  const SizedBox(height: 16),

                  // Información específica según el tipo
                  if (detalle.tipo == 'ingreso')
                    _buildSeccionIngreso(detalle)
                  else
                    _buildSeccionGasto(detalle),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    VerDetalleViewModel viewModel,
    DetalleTransaccion detalle,
  ) {
    // Símbolo de moneda fijo (dólares)
    String simboloMoneda = '\$';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: viewModel.colorTipo.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: viewModel.colorTipo.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: viewModel.colorTipo,
              shape: BoxShape.circle,
            ),
            child: Icon(viewModel.iconoTipo, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.tipoFormateado,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: viewModel.colorTipo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$simboloMoneda${detalle.monto.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: viewModel.colorTipo,
            ),
          ),
          // Mostrar número de factura si existe
          if (detalle.tipo == 'gasto' && 
              detalle.invoiceNumber != null && 
              detalle.invoiceNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: viewModel.colorTipo.withOpacity(0.3),
                ),
              ),
              child: Text(
                detalle.invoiceNumber!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: viewModel.colorTipo,
                ),
              ),
            ),
          ],
          // Mostrar badge de método de entrada si es IA
          if (detalle.tipo == 'gasto' && 
              detalle.entryMethod != null && 
              detalle.entryMethod!.toLowerCase() == 'ia') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'Registrado con IA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeccionInformacion(DetalleTransaccion detalle) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.category_outlined,
              label: 'Categoría',
              value: detalle.categoria,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha',
              value: formatoFecha.format(detalle.fecha),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.description_outlined,
              label: 'Descripción',
              value: detalle.descripcion.isNotEmpty
                  ? detalle.descripcion
                  : 'Sin descripción',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionIngreso(DetalleTransaccion detalle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles del Ingreso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (detalle.metodoPago != null && detalle.metodoPago!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.payment_outlined,
                label: 'Método de Pago',
                value: detalle.metodoPago!,
              ),
            if (detalle.metodoPago != null && detalle.metodoPago!.isNotEmpty)
              const SizedBox(height: 12),
            if (detalle.origen != null && detalle.origen!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.source_outlined,
                label: 'Origen',
                value: detalle.origen!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionGasto(DetalleTransaccion detalle) {
    return Column(
      children: [
        // Información de Identificación
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Identificación de Factura',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (detalle.invoiceNumber != null && detalle.invoiceNumber!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.numbers,
                    label: 'Número de Factura',
                    value: detalle.invoiceNumber!,
                  ),
                if (detalle.invoiceNumber != null && detalle.invoiceNumber!.isNotEmpty)
                  const SizedBox(height: 12),
                if (detalle.taxAmount != null && detalle.taxAmount! > 0)
                  _buildInfoRow(
                    icon: Icons.receipt_long,
                    label: 'Impuestos',
                    value: '\$${detalle.taxAmount!.toStringAsFixed(2)}',
                  ),
                if (detalle.taxAmount != null && detalle.taxAmount! > 0)
                  const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.calculate_outlined,
                  label: 'Total (con impuestos)',
                  value: '\$${detalle.monto.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Información del Proveedor
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏢 Proveedor (Emisor)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (detalle.supplierName != null && detalle.supplierName!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.business,
                    label: 'Nombre o Razón Social',
                    value: detalle.supplierName!,
                  ),
                if (detalle.supplierName != null && detalle.supplierName!.isNotEmpty)
                  const SizedBox(height: 12),
                if (detalle.supplierTaxId != null && detalle.supplierTaxId!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'NIF / RFC / RUT',
                    value: detalle.supplierTaxId!,
                  ),
                if (detalle.supplierTaxId != null && detalle.supplierTaxId!.isNotEmpty)
                  const SizedBox(height: 12),
                if (detalle.lugarLocal != null && detalle.lugarLocal!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: detalle.lugarLocal!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Información del Sistema
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔧 Información del Sistema',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (detalle.entryMethod != null && detalle.entryMethod!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.input_outlined,
                    label: 'Método de Registro',
                    value: detalle.entryMethod!,
                  ),
                if (detalle.entryMethod != null && detalle.entryMethod!.isNotEmpty)
                  const SizedBox(height: 12),
                if (detalle.createdAt != null)
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Fecha de Registro',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(detalle.createdAt!),
                  ),
                if (detalle.createdAt != null)
                  const SizedBox(height: 12),
                if (detalle.scanImagePath != null && detalle.scanImagePath!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.image_outlined,
                    label: 'Imagen Escaneada',
                    value: 'Disponible',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _navegarAEditar(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => EditTransactionViewModel(),
          child: EditTransactionView(
            transaccionId: widget.transaccionId,
            tipo: widget.tipo,
          ),
        ),
      ),
    );

    // Si se editó la transacción, recargar los detalles
    if (resultado == true && mounted) {
      _transaccionModificada = true; // Marcar que se modificó

      final viewModel = context.read<VerDetalleViewModel>();
      await viewModel.cargarDetalle(widget.transaccionId, widget.tipo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Transacción actualizada'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Transacción'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta transacción? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _eliminarTransaccion(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarTransaccion(BuildContext context) async {
    final viewModel = context.read<VerDetalleViewModel>();

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final exitoso = await viewModel.eliminarTransaccion();

    // Cerrar el indicador de carga
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (exitoso) {
      if (context.mounted) {
        _transaccionModificada =
            true; // Marcar que se eliminó (también es una modificación)

        // Volver a la pantalla anterior y retornar true para indicar que se eliminó/modificó
        Navigator.of(context).pop(true);

        // Mostrar mensaje de éxito en la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Transacción eliminada. Actualizando lista...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Limpiar el estado cuando se sale de la pantalla
    context.read<VerDetalleViewModel>().limpiar();
    super.dispose();
  }
}
