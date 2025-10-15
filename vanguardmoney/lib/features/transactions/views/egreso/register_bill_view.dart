import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/register_bill_viewmodel.dart';
import '../../viewmodels/categoria_viewmodel.dart';
import '../../models/categoria_model.dart';
import '../../services/validaciones.dart';
import '../gestionar_categorias_view.dart';

// Provider para el ViewModel
final registerBillViewModelProvider =
    ChangeNotifierProvider<RegisterBillViewModel>(
      (ref) => RegisterBillViewModel(),
    );

// Provider para el ViewModel de categorías
final categoriaViewModelProvider = ChangeNotifierProvider<CategoriaViewModel>(
  (ref) => CategoriaViewModel(),
);

class RegisterBillView extends ConsumerStatefulWidget {
  final String idUsuario;
  final Map<String, dynamic>? datosIniciales;
  
  const RegisterBillView({
    Key? key,
    required this.idUsuario,
    this.datosIniciales,
  }) : super(key: key);

  @override
  ConsumerState<RegisterBillView> createState() => _RegisterBillViewState();
}

class _RegisterBillViewState extends ConsumerState<RegisterBillView> {
  @override
  void initState() {
    super.initState();
    // Cargar categorías y prellenar datos si vienen de la IA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoriaViewModelProvider)
          .cargarCategorias(widget.idUsuario, TipoCategoria.egreso);
      
      // Si hay datos iniciales de la IA, prellenar los campos
      if (widget.datosIniciales != null) {
        final viewModel = ref.read(registerBillViewModelProvider);
        final datos = widget.datosIniciales!;
        
        viewModel.proveedorController.text = datos['proveedor']?.toString() ?? '';
        viewModel.montoController.text = datos['monto']?.toString() ?? '';
        viewModel.descripcionController.text = datos['descripcion']?.toString() ?? '';
        viewModel.lugarLocalController.text = datos['lugarLocal']?.toString() ?? '';
        
        // Seleccionar la categoría si existe
        final categoria = datos['categoria']?.toString();
        if (categoria != null && categoria.isNotEmpty) {
          viewModel.setCategoria(categoria);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(registerBillViewModelProvider);
    final categoriaViewModel = ref.watch(categoriaViewModelProvider);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Registrar Egreso'),
            if (widget.datosIniciales != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16),
                    SizedBox(width: 4),
                    Text('IA', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Datos del Egreso',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Banner informativo si los datos vienen de la IA
                  if (widget.datosIniciales != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Datos extraídos con IA. Revisa y confirma antes de guardar.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: viewModel.proveedorController,
                    decoration: InputDecoration(
                      labelText: 'Proveedor',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: validarProveedor,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: viewModel.montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: validarMonto,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: viewModel.descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: validarDescripcion,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: viewModel.lugarLocalController,
                    decoration: InputDecoration(
                      labelText: 'Lugar/Local',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: validarLugarLocal,
                  ),
                  const SizedBox(height: 16),
                  // Sección de categorías con botón para gestionar
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: viewModel.categoriaSeleccionada,
                          items: categoriaViewModel
                              .obtenerNombresCategorias(TipoCategoria.egreso)
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                          onChanged: viewModel.setCategoria,
                          validator: validarCategoria,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => GestionarCategoriasView(
                                  idUsuario: widget.idUsuario,
                                  tipo: TipoCategoria.egreso,
                                ),
                              ),
                            );
                            // Recargar categorías después de volver
                            categoriaViewModel.cargarCategorias(
                              widget.idUsuario,
                              TipoCategoria.egreso,
                            );
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.deepOrange,
                          ),
                          tooltip: 'Gestionar categorías',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Registrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await viewModel.guardarFacturaEnFirebase(
                            widget.idUsuario,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Egreso registrado correctamente',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
