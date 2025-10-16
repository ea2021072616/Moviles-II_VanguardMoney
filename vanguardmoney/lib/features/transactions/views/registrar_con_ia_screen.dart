import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../viewmodels/registrar_IA_viewmodel.dart';
import '../viewmodels/registrar_voz_viewmodel.dart';
import 'egreso/register_bill_view.dart';
import 'registrar_con_voz_screen.dart';

/// Pantalla para registrar transacciones escaneando imágenes con IA
class RegistrarConIAScreen extends StatefulWidget {
  final String? idUsuario;
  
  const RegistrarConIAScreen({super.key, this.idUsuario});

  @override
  State<RegistrarConIAScreen> createState() => _RegistrarConIAScreenState();
}

class _RegistrarConIAScreenState extends State<RegistrarConIAScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializar Gemini al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
      viewModel.initializeGeminiModel();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen primero')));
      return;
    }

    final idUsuario = widget.idUsuario ?? 'usuario_default';
    final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
    
    // Inicializar Gemini si no está inicializado
    if (viewModel.errorMessage == null) {
      await viewModel.initializeGeminiModel();
    }
    
    // Analizar imagen
    await viewModel.escanearYExtraerFactura(_selectedImage!.path, idUsuario);
    
    if (!mounted) return;
    
    // Si hubo error, mostrar mensaje
    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
      return;
    }
    
    // Si se extrajeron datos, ir directo al formulario de registro
    if (viewModel.datosExtraidos != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterBillView(
            idUsuario: idUsuario,
            datosIniciales: viewModel.datosExtraidos,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 24),
            SizedBox(width: 8),
            Text('Escanear Factura con IA'),
          ],
        ),
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
                        'Analiza tu factura',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La IA extraerá los datos automáticamente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón para registrar con voz
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => RegistrarMedianteVozViewModel(),
                            child: RegistrarConVozScreen(
                              idUsuario: widget.idUsuario ?? 'usuario_default',
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mic, size: 24),
                    label: const Text(
                      'Registrar con Voz',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                // Divisor con texto
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o escanea tu factura',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  ],
                ),

                const SizedBox(height: 16),

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
                            viewModel.isLoading ? 'Analizando con IA...' : 'Analizar con IA',
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

                // Tips informativos
                Column(
                  children: [
                    // Tip de voz
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic, color: Colors.purple[600], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '¿Prefieres hablar? Usa el registro por voz y la IA detectará automáticamente si es ingreso o egreso.',
                              style: TextStyle(color: Colors.purple[700], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tip de escaneo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.indigo[600], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Toma una foto de tu factura y la IA extraerá automáticamente todos los datos.',
                              style: TextStyle(color: Colors.indigo[700], fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}