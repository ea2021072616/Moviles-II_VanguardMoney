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
  const RegisterBillView({Key? key, required this.idUsuario}) : super(key: key);

  @override
  ConsumerState<RegisterBillView> createState() => _RegisterBillViewState();
}

class _RegisterBillViewState extends ConsumerState<RegisterBillView> {
  @override
  void initState() {
    super.initState();
    // Cargar categorías al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categoriaViewModelProvider)
          .cargarCategorias(widget.idUsuario, TipoCategoria.egreso);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(registerBillViewModelProvider);
    final categoriaViewModel = ref.watch(categoriaViewModelProvider);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Egreso'),
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
                  const SizedBox(height: 24),
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
