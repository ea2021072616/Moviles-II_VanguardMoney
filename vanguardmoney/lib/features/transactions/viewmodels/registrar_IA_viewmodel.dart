import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/categoria_model.dart';

class RegistrarMedianteIAViewModel extends ChangeNotifier {
  GenerativeModel? _model;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _datosExtraidos;
  String? _categoriaSugerida;
  bool _categoriaConfirmada = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get datosExtraidos => _datosExtraidos;
  String? get categoriaSugerida => _categoriaSugerida;
  bool get categoriaConfirmada => _categoriaConfirmada;

  /// Inicializa el modelo Gemini usando Firebase AI
  Future<void> initializeGeminiModel() async {
    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash-exp',
      );
      
      if (kDebugMode) {
        print('✅ Modelo Gemini inicializado correctamente');
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al inicializar el modelo: $e';
      if (kDebugMode) {
        print('❌ Error en initializeGeminiModel: $e');
      }
      notifyListeners();
    }
  }

  Future<void> escanearYExtraerFactura(String imagePath, String idUsuario) async {
    // Inicializar Gemini si no está inicializado
    if (_model == null) {
      await initializeGeminiModel();
    }

    _isLoading = true;
    _errorMessage = null;
    _datosExtraidos = null;
    _categoriaSugerida = null;
    _categoriaConfirmada = false;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('�️ ANALIZANDO IMAGEN CON GEMINI...');
        debugPrint('📁 Ruta: $imagePath');
        debugPrint('═══════════════════════════════════════');
      }

      // Analizar imagen directamente con Gemini (sin OCR)
      final datosIA = await _analizarImagenConGemini(imagePath);
      
      if (datosIA == null) {
        _errorMessage = _errorMessage ?? 'No se pudo analizar la imagen con IA';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Agregar datos adicionales
      datosIA['idUsuario'] = idUsuario;
      
      _datosExtraidos = datosIA;
      _categoriaSugerida = datosIA['categoria'];
      
      if (kDebugMode) {
        debugPrint('🤖 DATOS EXTRAÍDOS CON GEMINI:');
        debugPrint('Proveedor: ${datosIA['proveedor']}');
        debugPrint('Monto: ${datosIA['monto']}');
        debugPrint('Descripción: ${datosIA['descripcion']}');
        debugPrint('Lugar: ${datosIA['lugarLocal']}');
        debugPrint('Categoría: ${datosIA['categoria']}');
        debugPrint('═══════════════════════════════════════');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al procesar imagen: $e';
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('❌ Error: $e');
      }
      notifyListeners();
    }
  }

  /// Analiza la imagen directamente con Gemini Vision y retorna datos estructurados
  Future<Map<String, dynamic>?> _analizarImagenConGemini(String imagePath) async {
    if (_model == null) {
      _errorMessage = 'El modelo Gemini no está inicializado';
      return null;
    }

    try {
      // Leer la imagen como bytes
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Obtener las categorías disponibles
      final categoriasDisponibles = CategoriaModel.categoriasBaseEgresos
          .map((c) => c.nombre)
          .join(', ');

      final prompt = '''
Analiza esta imagen de factura y extrae la información relevante.

Responde ÚNICAMENTE con un objeto JSON válido (sin markdown, sin bloques de código) con esta estructura exacta:
{
  "proveedor": "nombre del negocio o empresa",
  "monto": "monto total a pagar (solo números con punto decimal, ej: 150.50)",
  "descripcion": "descripción breve de los productos o servicios",
  "lugarLocal": "dirección o ubicación del negocio",
  "categoria": "una de estas categorías: $categoriasDisponibles"
}

REGLAS IMPORTANTES:
- Si no encuentras un campo, usa un string vacío ""
- El monto debe ser solo números con punto decimal (ej: "125.50")
- La categoría DEBE ser una de las listadas arriba (elige la más apropiada basándote en el tipo de negocio)
- NO incluyas símbolos de moneda en el monto
- NO incluyas bloques de código markdown
- Responde SOLO con el JSON, nada más
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ])
      ];
      
      final response = await _model!.generateContent(content);
      
      if (response.text == null) {
        _errorMessage = 'Gemini no generó respuesta';
        return null;
      }

      // Limpiar respuesta
      String jsonString = response.text!.trim();
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*'), '');
      jsonString = jsonString.trim();
      
      if (kDebugMode) {
        debugPrint('📥 Respuesta de Gemini: $jsonString');
      }

      // Parsear JSON
      final Map<String, dynamic> result = json.decode(jsonString);
      
      // Validar campos requeridos
      final camposRequeridos = ['proveedor', 'monto', 'descripcion', 'lugarLocal', 'categoria'];
      for (final campo in camposRequeridos) {
        if (!result.containsKey(campo)) {
          result[campo] = '';
        }
      }

      // Guardar categoría sugerida
      result['categoriaSugerida'] = result['categoria'];
      result['textoCompleto'] = 'Imagen analizada por Gemini Vision';
      
      return result;
      
    } catch (e) {
      _errorMessage = 'Error al analizar imagen con Gemini: $e';
      if (kDebugMode) {
        debugPrint('❌ Error en _analizarImagenConGemini: $e');
      }
      return null;
    }
  }



  void confirmarCategoria(String categoria) {
    _categoriaSugerida = categoria;
    _categoriaConfirmada = true;
    if (_datosExtraidos != null) {
      _datosExtraidos!['categoria'] = categoria;
      _datosExtraidos!['categoriaSugerida'] = categoria;
    }
    notifyListeners();
  }

  void cambiarCategoria(String nuevaCategoria) {
    _categoriaSugerida = nuevaCategoria;
    _categoriaConfirmada = true;
    if (_datosExtraidos != null) {
      _datosExtraidos!['categoria'] = nuevaCategoria;
    }
    notifyListeners();
  }

  void limpiarDatos() {
    _datosExtraidos = null;
    _categoriaSugerida = null;
    _categoriaConfirmada = false;
    _errorMessage = null;
    notifyListeners();
  }
}
