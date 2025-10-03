import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// ...existing code...
import '../viewmodels/registrar_IA_viewmodel.dart';

/// Pantalla para registrar transacciones usando Firebase AI (Gemini)
class RegistrarConIAScreen extends StatefulWidget {
  final String? idUsuario;
  
  const RegistrarConIAScreen({super.key, this.idUsuario});

  @override
  State<RegistrarConIAScreen> createState() => _RegistrarConIAScreenState();
}

class _RegistrarConIAScreenState extends State<RegistrarConIAScreen> {
  Map<String, dynamic>? _extractedData;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar el modelo al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
      viewModel.initializeGeminiModel();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // text input flow removed — only image-based analysis is used

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
      _extractedData = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen primero')));
      return;
    }

    final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
    final result = await viewModel.analyzeImage(_selectedImage!.path);

    if (result != null) {
      setState(() {
        _extractedData = result;
      });
    } else if (viewModel.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar con IA'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RegistrarMedianteIAViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con ícono
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¿Qué transacción realizaste?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Secondary helper message removed per request
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // (Text input flow removed) - usa imagen para analizar

                // Área de selección de imagen
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar foto'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Seleccionar'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: viewModel.isLoading ? null : _analyzeImage,
                          icon: viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            viewModel.isLoading ? 'Analizando imagen...' : 'Procesar imagen',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Resultados
                if (_extractedData != null) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Datos Extraídos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildDataRow(
                            'Tipo',
                            _extractedData!['tipo'] ?? 'N/A',
                            _extractedData!['tipo'] == 'ingreso' ? Icons.trending_up : Icons.trending_down,
                            _extractedData!['tipo'] == 'ingreso' ? Colors.green : Colors.deepOrange,
                          ),
                          _buildDataRow(
                            'Monto',
                            '\$${_extractedData!['monto'] ?? 'N/A'}',
                            Icons.attach_money,
                            Colors.indigo,
                          ),
                          _buildDataRow(
                            'Categoría',
                            _extractedData!['categoria'] ?? 'N/A',
                            Icons.category,
                            Colors.purple,
                          ),
                          _buildDataRow(
                            'Descripción',
                            _extractedData!['descripcion'] ?? 'N/A',
                            Icons.description,
                            Colors.blue,
                          ),
                          _buildDataRow(
                            'Fecha',
                            _extractedData!['fecha'] ?? 'N/A',
                            Icons.calendar_today,
                            Colors.orange,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _extractedData = null;
                                      _selectedImage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Nueva'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[400]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
                                    // Mostrar indicador mientras guarda
                                    final success = await viewModel.saveParsedTransaction(_extractedData!, widget.idUsuario);
                                    if (mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transacción guardada correctamente')));
                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage ?? 'Error al guardar')));
                                      }
                                    }
                                  },
                                  icon: viewModel.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: Text(
                                    viewModel.isLoading ? 'Guardando...' : 'Guardar',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Tip informativo
                if (_extractedData == null)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.indigo[600], size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Puedes elegir entre tomar una foto o seleccionar una imagen de tu galería para analizar la transacción.',
                            style: TextStyle(color: Colors.indigo[700], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // La función de guardado local fue reemplazada por el método del ViewModel
}