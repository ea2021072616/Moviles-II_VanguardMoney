import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/Ver_transacciones_viewmodel.dart';
import '../viewmodels/ver_detalle_viewmodel.dart';
import '../services/filtros.dart';
import '../../../core/theme/app_colors.dart';
import 'ver_detalle_view.dart';

class VerTransaccionesView extends StatefulWidget {
  const VerTransaccionesView({Key? key}) : super(key: key);

  @override
  State<VerTransaccionesView> createState() => _VerTransaccionesViewState();
}

class _VerTransaccionesViewState extends State<VerTransaccionesView> {
  late ServicioBusquedaTransacciones _servicioBusqueda;
  CriteriosBusqueda _criteriosBusqueda = const CriteriosBusqueda();
  bool _mostrarFiltros = false;
  late VerTransaccionesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _servicioBusqueda = ServicioBusquedaTransacciones();
    _viewModel = VerTransaccionesViewModel();
    // Cargar datos cuando se inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.cargarTransacciones();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Método para formatear números como moneda
  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }



  // Método para formatear fechas
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Método para formatear fechas solo día/mes/año (para filtros)
  String _formatDateOnly(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Método para navegar al detalle de una transacción
  Future<void> _navegarADetalle(TransaccionItem transaccion) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => VerDetalleViewModel(),
          child: VerDetalleView(
            transaccionId: transaccion.id,
            tipo: transaccion.tipo,
          ),
        ),
      ),
    );

    // Si se modificó la transacción (editó o eliminó), recargar la lista
    if (resultado == true && mounted) {
      // Recargar la lista de transacciones
      await _viewModel.refrescar();

      // Mostrar confirmación de que se actualizó
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Lista actualizada'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VerTransaccionesViewModel>.value(
      value: _viewModel,
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
            // Botón para mostrar/ocultar filtros
            IconButton(
              onPressed: () {
                setState(() {
                  _mostrarFiltros = !_mostrarFiltros;
                });
              },
              icon: Icon(
                _mostrarFiltros ? Icons.filter_list_off : Icons.filter_list,
                color: AppColors.white,
              ),
              tooltip: _mostrarFiltros ? 'Ocultar filtros' : 'Mostrar filtros',
            ),
            IconButton(
              onPressed: () {
                final viewModel = context.read<VerTransaccionesViewModel>();
                _refrescarDatos(viewModel);
              },
              icon: const Icon(Icons.refresh, color: AppColors.white),
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: Consumer<VerTransaccionesViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Panel de filtros expandible
                if (_mostrarFiltros) _buildPanelFiltros(viewModel),
                // Lista de transacciones
                Expanded(child: _buildTransaccionesList(viewModel)),
              ],
            );
          },
        ),
        floatingActionButton: Consumer<VerTransaccionesViewModel>(
          builder: (context, viewModel, child) {
            return FloatingActionButton(
              onPressed: () => _refrescarDatos(viewModel),
              backgroundColor: AppColors.blueClassic,
              child: const Icon(Icons.add, color: AppColors.white),
              tooltip: 'Agregar transacción',
            );
          },
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
              style: TextStyle(fontSize: 16, color: AppColors.greyDark),
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
            Icon(Icons.error_outline, size: 64, color: AppColors.redCoral),
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
                style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final viewModel = context.read<VerTransaccionesViewModel>();
                _refrescarDatos(viewModel);
              },
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

    // Aplicar filtros a las transacciones
    final transaccionesFiltradas = _servicioBusqueda.filtrarTransacciones(
      viewModel.transacciones,
      _criteriosBusqueda,
    );

    if (transaccionesFiltradas.isEmpty) {
      final mensaje = _criteriosBusqueda.tienesFiltrosActivos
          ? 'No hay transacciones que coincidan con los filtros'
          : 'No hay transacciones';
      final descripcion = _criteriosBusqueda.tienesFiltrosActivos
          ? 'Intenta ajustar los filtros para ver más resultados'
          : 'Tus transacciones aparecerán aquí';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _criteriosBusqueda.tienesFiltrosActivos
                  ? Icons.search_off
                  : Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: TextStyle(fontSize: 14, color: AppColors.greyDark),
            ),
            if (_criteriosBusqueda.tienesFiltrosActivos) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueClassic,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refrescarDatos(viewModel),
      color: AppColors.blueClassic,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: transaccionesFiltradas.length,
        itemBuilder: (context, index) {
          final transaccion = transaccionesFiltradas[index];
          return _buildTransaccionCard(transaccion);
        },
      ),
    );
  }

  Widget _buildTransaccionCard(TransaccionItem transaccion) {
    final bool esIngreso = transaccion.tipo == 'ingreso';
    final Color colorPrincipal = esIngreso
        ? const Color(0xFF377CC8)
        : AppColors.redCoral;
    final IconData icono = esIngreso ? Icons.add_circle : Icons.remove_circle;
    
    // Símbolo de moneda fijo
    final String simboloMoneda = '\$';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navegarADetalle(transaccion),
        borderRadius: BorderRadius.circular(12),
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
              child: Icon(icono, color: colorPrincipal, size: 24),
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
                  '${esIngreso ? '+' : '-'}$simboloMoneda${_formatCurrency(transaccion.monto)}',
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
                    style: TextStyle(color: AppColors.greyDark, fontSize: 14),
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
                      style: TextStyle(color: AppColors.greyDark, fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
            trailing: Icon(Icons.chevron_right, color: AppColors.greyMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelFiltros(VerTransaccionesViewModel viewModel) {
    return Container(
      color: AppColors.greyLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del panel
          Row(
            children: [
              const Icon(Icons.filter_list, color: AppColors.blueClassic),
              const SizedBox(width: 8),
              Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark,
                ),
              ),
              const Spacer(),
              if (_criteriosBusqueda.tienesFiltrosActivos)
                TextButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.redCoral,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filtro por tipo de transacción
          _buildFiltroTipo(),
          const SizedBox(height: 16),

          // Filtro por categoría
          _buildFiltroCategoria(viewModel),
          const SizedBox(height: 16),

          // Filtros de fecha
          _buildFiltrosFecha(),
          const SizedBox(height: 16),

          // Criterio de ordenamiento
          _buildCriterioOrden(),
        ],
      ),
    );
  }

  Widget _buildFiltroTipo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de movimiento',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChipFiltro(
              'Todos',
              _criteriosBusqueda.tipoFiltro == TipoFiltro.todos,
              () => _actualizarFiltroTipo(TipoFiltro.todos),
            ),
            const SizedBox(width: 8),
            _buildChipFiltro(
              'Ingresos',
              _criteriosBusqueda.tipoFiltro == TipoFiltro.ingresos,
              () => _actualizarFiltroTipo(TipoFiltro.ingresos),
            ),
            const SizedBox(width: 8),
            _buildChipFiltro(
              'Gastos',
              _criteriosBusqueda.tipoFiltro == TipoFiltro.gastos,
              () => _actualizarFiltroTipo(TipoFiltro.gastos),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltroCategoria(VerTransaccionesViewModel viewModel) {
    final categorias = _servicioBusqueda.obtenerCategorias(
      viewModel.transacciones,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        if (categorias.isEmpty)
          Text(
            'No hay categorías disponibles',
            style: TextStyle(fontSize: 12, color: AppColors.greyDark),
          )
        else
          DropdownButtonFormField<String>(
            value: _criteriosBusqueda.categoriaFiltro,
            decoration: InputDecoration(
              hintText: 'Todas las categorías',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ...categorias.map(
                (categoria) => DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                ),
              ),
            ],
            onChanged: _actualizarFiltroCategoria,
          ),
      ],
    );
  }

  Widget _buildFiltrosFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de fechas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Fecha de inicio
            Expanded(
              child: InkWell(
                onTap: () => _seleccionarFecha(true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyMedium),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.greyDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _criteriosBusqueda.fechaInicio != null
                            ? _formatDateOnly(_criteriosBusqueda.fechaInicio!)
                            : 'Fecha inicio',
                        style: TextStyle(
                          color: _criteriosBusqueda.fechaInicio != null
                              ? AppColors.greyDark
                              : AppColors.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Fecha de fin
            Expanded(
              child: InkWell(
                onTap: () => _seleccionarFecha(false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyMedium),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.greyDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _criteriosBusqueda.fechaFin != null
                            ? _formatDateOnly(_criteriosBusqueda.fechaFin!)
                            : 'Fecha fin',
                        style: TextStyle(
                          color: _criteriosBusqueda.fechaFin != null
                              ? AppColors.greyDark
                              : AppColors.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCriterioOrden() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChipFiltro(
              'Fecha reciente',
              _criteriosBusqueda.criterioOrden == CriterioOrden.fechaReciente,
              () => _actualizarCriterioOrden(CriterioOrden.fechaReciente),
            ),
            const SizedBox(width: 8),
            _buildChipFiltro(
              'Fecha antigua',
              _criteriosBusqueda.criterioOrden == CriterioOrden.fechaAntigua,
              () => _actualizarCriterioOrden(CriterioOrden.fechaAntigua),
            ),
            const SizedBox(width: 8),
            _buildChipFiltro(
              'Categoría',
              _criteriosBusqueda.criterioOrden == CriterioOrden.categoria,
              () => _actualizarCriterioOrden(CriterioOrden.categoria),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipFiltro(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueClassic : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.blueClassic : AppColors.greyMedium,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.greyDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Métodos para actualizar filtros
  void _actualizarFiltroTipo(TipoFiltro tipo) {
    setState(() {
      _criteriosBusqueda = _criteriosBusqueda.copyWith(tipoFiltro: tipo);
    });
  }

  void _actualizarFiltroCategoria(String? categoria) {
    setState(() {
      if (categoria == null) {
        // Cuando se selecciona "Todas las categorías", limpiar el filtro
        _criteriosBusqueda = _criteriosBusqueda.copyWith(
          limpiarCategoria: true,
        );
      } else {
        // Cuando se selecciona una categoría específica
        _criteriosBusqueda = _criteriosBusqueda.copyWith(
          categoriaFiltro: categoria,
        );
      }
    });
  }

  void _actualizarCriterioOrden(CriterioOrden criterio) {
    setState(() {
      _criteriosBusqueda = _criteriosBusqueda.copyWith(criterioOrden: criterio);
    });
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: esInicio
          ? (_criteriosBusqueda.fechaInicio ?? DateTime.now())
          : (_criteriosBusqueda.fechaFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blueClassic,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esInicio) {
          _criteriosBusqueda = _criteriosBusqueda.copyWith(
            fechaInicio: fechaSeleccionada,
          );
        } else {
          _criteriosBusqueda = _criteriosBusqueda.copyWith(
            fechaFin: fechaSeleccionada,
          );
        }
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _criteriosBusqueda = _criteriosBusqueda.limpiarFiltros();
    });
  }

  Future<void> _refrescarDatos(VerTransaccionesViewModel viewModel) async {
    await viewModel.cargarTransacciones();
  }
}
