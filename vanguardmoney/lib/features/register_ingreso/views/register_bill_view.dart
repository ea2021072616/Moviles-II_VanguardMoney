import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_bill_viewmodel.dart';
import '../../register_ingreso/services/validaciones.dart';

class RegisterBillView extends StatelessWidget {
  final String idUsuario;
  const RegisterBillView({Key? key, required this.idUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterBillViewModel(),
      child: Consumer<RegisterBillViewModel>(
        builder: (context, viewModel, _) {
          final formKey = GlobalKey<FormState>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Registrar Factura'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: viewModel.proveedorController,
                      decoration: const InputDecoration(labelText: 'Proveedor'),
                      validator: validarProveedor,
                    ),
                    TextFormField(
                      controller: viewModel.montoController,
                      decoration: const InputDecoration(labelText: 'Monto'),
                      keyboardType: TextInputType.number,
                      validator: validarMonto,
                    ),
                    TextFormField(
                      controller: viewModel.descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      validator: validarDescripcion,
                    ),
                    TextFormField(
                      controller: viewModel.lugarLocalController,
                      decoration: const InputDecoration(labelText: 'Lugar/Local'),
                      validator: validarLugarLocal,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await viewModel.guardarFacturaEnFirebase(idUsuario);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Factura registrada correctamente')),
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