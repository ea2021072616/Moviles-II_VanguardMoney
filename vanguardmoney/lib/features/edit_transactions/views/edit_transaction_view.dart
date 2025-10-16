import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/edit_transactions_viwmodel.dart';
import '../../../core/theme/app_colors.dart';

class EditTransactionView extends StatefulWidget {
  final String transaccionId;
  final String tipo; // 'ingreso' o 'gasto'

  const EditTransactionView({
    Key? key,
    required this.transaccionId,
    required this.tipo,
  }) : super(key: key);

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Cargar los datos de la transacción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditTransactionViewModel>().cargarTransaccion(
        widget.transaccionId,
        widget.tipo,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final esIngreso = widget.tipo == 'ingreso';

    return Scaffold(
      appBar: AppBar(
        title: Text(esIngreso ? 'Editar Ingreso' : 'Editar Gasto'),
        backgroundColor: esIngreso ? Colors.green : AppColors.redCoral,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarCambios,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: Consumer<EditTransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos...'),
                ],
              ),
            );
          }

          if (viewModel.error != null && !viewModel.isSaving) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.cargarTransaccion(
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de tipo
                    _buildTipoIndicador(esIngreso),
                    const SizedBox(height: 24),

                    // Campo Monto
                    _buildMontoField(viewModel),
                    const SizedBox(height: 16),

                    // Campo Categoría
                    _buildCategoriaField(viewModel),
                    const SizedBox(height: 16),

                    // Campo Descripción
                    _buildDescripcionField(viewModel),
                    const SizedBox(height: 16),

                    // Campos específicos según el tipo
                    if (esIngreso) ...[
                      // Fecha (solo para ingresos)
                      _buildFechaField(viewModel),
                      const SizedBox(height: 16),

                      // Método de pago
                      _buildMetodoPagoField(viewModel),
                      const SizedBox(height: 16),

                      // Origen
                      _buildOrigenField(viewModel),
                    ] else ...[
                      // Proveedor
                      _buildProveedorField(viewModel),
                      const SizedBox(height: 16),

                      // Lugar
                      _buildLugarField(viewModel),
                    ],

                    const SizedBox(height: 24),

                    // Mostrar error si existe
                    if (viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isSaving ? null : _guardarCambios,
                        icon: viewModel.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          viewModel.isSaving
                              ? 'Guardando...'
                              : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: esIngreso
                              ? Colors.green
                              : AppColors.redCoral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipoIndicador(bool esIngreso) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (esIngreso ? Colors.green : AppColors.redCoral).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (esIngreso ? Colors.green : AppColors.redCoral).withOpacity(
            0.3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            esIngreso ? Icons.arrow_upward : Icons.arrow_downward,
            color: esIngreso ? Colors.green : AppColors.redCoral,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            'Editando ${esIngreso ? 'Ingreso' : 'Gasto'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: esIngreso ? Colors.green : AppColors.redCoral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontoField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.montoController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto',
        prefixText: '\$ ',
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El monto es requerido';
        }
        final monto = double.tryParse(value);
        if (monto == null || monto <= 0) {
          return 'Ingrese un monto válido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoriaField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.categoriaController,
      decoration: InputDecoration(
        labelText: 'Categoría',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'La categoría es requerida';
        }
        return null;
      },
    );
  }

  Widget _buildDescripcionField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.descripcionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Descripción',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildFechaField(EditTransactionViewModel viewModel) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return InkWell(
      onTap: () => _seleccionarFecha(viewModel),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          formatoFecha.format(viewModel.fechaSeleccionada),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMetodoPagoField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.metodoPagoController,
      decoration: InputDecoration(
        labelText: 'Método de Pago',
        prefixIcon: const Icon(Icons.payment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El método de pago es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildOrigenField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.origenController,
      decoration: InputDecoration(
        labelText: 'Origen',
        prefixIcon: const Icon(Icons.source),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El origen es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildProveedorField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.proveedorController,
      decoration: InputDecoration(
        labelText: 'Proveedor',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El proveedor es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildLugarField(EditTransactionViewModel viewModel) {
    return TextFormField(
      controller: viewModel.lugarController,
      decoration: InputDecoration(
        labelText: 'Lugar',
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El lugar es requerido';
        }
        return null;
      },
    );
  }

  Future<void> _seleccionarFecha(EditTransactionViewModel viewModel) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: viewModel.fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      // Ahora seleccionar la hora
      final TimeOfDay? horaSeleccionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(viewModel.fechaSeleccionada),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (horaSeleccionada != null) {
        final nuevaFecha = DateTime(
          fechaSeleccionada.year,
          fechaSeleccionada.month,
          fechaSeleccionada.day,
          horaSeleccionada.hour,
          horaSeleccionada.minute,
        );
        viewModel.actualizarFecha(nuevaFecha);
      }
    }
  }

  Future<void> _guardarCambios() async {
    // Validar formulario
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<EditTransactionViewModel>();

      // Mostrar diálogo de confirmación
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmar cambios'),
            content: const Text(
              '¿Estás seguro de que deseas guardar estos cambios?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (confirmar == true) {
        final exitoso = await viewModel.guardarCambios();

        if (exitoso && mounted) {
          // Mostrar mensaje de éxito y regresar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Cambios guardados exitosamente')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Regresar a la pantalla anterior con true para indicar que se editó
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  @override
  void dispose() {
    context.read<EditTransactionViewModel>().limpiar();
    super.dispose();
  }
}
