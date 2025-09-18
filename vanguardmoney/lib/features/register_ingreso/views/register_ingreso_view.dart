import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/registrar_ingreso_viewmodel.dart';
import '../services/validaciones.dart';

class RegisterIngresoView extends StatelessWidget {
  final String idUsuario;
  const RegisterIngresoView({Key? key, required this.idUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrarIngresoViewModel(),
      child: Consumer<RegistrarIngresoViewModel>(
        builder: (context, viewModel, _) {
          final formKey = GlobalKey<FormState>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Registrar Ingreso'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: viewModel.montoController,
                      decoration: const InputDecoration(labelText: 'Monto'),
                      keyboardType: TextInputType.number,
                      validator: validarMonto,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          viewModel.setFecha(pickedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Fecha'),
                          controller: TextEditingController(
                            text: viewModel.fecha != null
                                ? "${viewModel.fecha!.day}/${viewModel.fecha!.month}/${viewModel.fecha!.year}"
                                : '',
                          ),
                          validator: (_) => validarFecha(viewModel.fecha),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: viewModel.descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: validarDescripcion,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: viewModel.categoriaSeleccionada,
                      items: RegistrarIngresoViewModel.categorias
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: viewModel.setCategoria,
                      validator: validarCategoria,
                    ),
                    TextFormField(
                      controller: viewModel.metodoPagoController,
                      decoration: const InputDecoration(labelText: 'Método de Pago'),
                      validator: validarMetodoPago,
                    ),
                    TextFormField(
                      controller: viewModel.origenController,
                      decoration: const InputDecoration(labelText: 'Origen'),
                      validator: validarOrigen,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await viewModel.guardarIngresoEnFirebase(idUsuario);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ingreso registrado correctamente')),
                          );
                        }
                      },
                      child: const Text('Registrar'),
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
}