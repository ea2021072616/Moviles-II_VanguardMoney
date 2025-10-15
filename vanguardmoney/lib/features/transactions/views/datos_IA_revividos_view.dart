import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/registrar_IA_viewmodel.dart';
import '../models/categoria_model.dart';

class DatosIARevividosView extends StatelessWidget {
  final String imagePath;
  final String idUsuario;
  const DatosIARevividosView({
    Key? key,
    required this.imagePath,
    required this.idUsuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrarMedianteIAViewModel()..escanearYExtraerFactura(imagePath, idUsuario),
      child: Scaffold(
        appBar: AppBar(title: const Text('Datos extraídos de la imagen')),
        body: Consumer<RegistrarMedianteIAViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(child: Text(vm.errorMessage!));
            }
            final datos = vm.datosExtraidos;
            if (datos == null) {
              return const Center(child: Text('No se extrajeron datos.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _datoTile('Proveedor', datos['proveedor']),
                _datoTile('Monto', datos['monto']?.toString()),
                _datoTile('Descripción', datos['descripcion']),
                _datoTile('Lugar/Local', datos['lugarLocal']),
                _buildCategoriaSelector(context, vm, datos),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _datoTile(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value ?? '-'),
    );
  }

  Widget _buildCategoriaSelector(
    BuildContext context,
    RegistrarMedianteIAViewModel vm,
    Map<String, dynamic> datos,
  ) {
    final categorias = CategoriaModel.categoriasBaseEgresos;
    final categoriaActual = datos['categoria'] as String?;
    final categoriaSugerida = datos['categoriaSugerida'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Categoría',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (categoriaSugerida != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sugerencia: $categoriaSugerida',
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No se pudo sugerir una categoría. Por favor selecciona una.',
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: categoriaActual?.isNotEmpty == true ? categoriaActual : null,
              decoration: const InputDecoration(
                labelText: 'Selecciona una categoría',
                border: OutlineInputBorder(),
              ),
              items: categorias.map((cat) {
                return DropdownMenuItem(
                  value: cat.nombre,
                  child: Text(cat.nombre),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  vm.cambiarCategoria(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
