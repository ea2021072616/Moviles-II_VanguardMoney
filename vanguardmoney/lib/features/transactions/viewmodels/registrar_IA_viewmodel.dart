import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelos de transacciones
import '../models/register_bill_model.dart';
import '../models/registro_ingreso_model.dart';

/// ViewModel para registrar transacciones mediante IA usando Firebase AI (Gemini)
class RegistrarMedianteIAViewModel extends ChangeNotifier {
  GenerativeModel? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String? _generatedText;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get generatedText => _generatedText;

  /// Inicializa el modelo Gemini usando Firebase AI
  /// Este método debe ser llamado antes de usar cualquier funcionalidad de IA
  Future<void> initializeGeminiModel() async {
    try {
      // Inicializar el modelo Gemini usando Firebase AI
      // No necesita API key porque usa Firebase Authentication
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash', // Modelo solicitado
      );
      
      if (kDebugMode) {
        print('Modelo Gemini inicializado correctamente');
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al inicializar el modelo: $e';
      if (kDebugMode) {
        print('Error en initializeGeminiModel: $e');
      }
      notifyListeners();
    }
  }

  /// Genera contenido de texto basado en un prompt
  /// 
  /// [prompt] - La instrucción o pregunta para el modelo
  /// Retorna el texto generado por la IA
  Future<String?> generateContent(String prompt) async {
    if (_model == null) {
      _errorMessage = 'El modelo no ha sido inicializado. Llama a initializeGeminiModel() primero.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      _generatedText = response.text;
      _isLoading = false;
      notifyListeners();
      
      return _generatedText;
    } catch (e) {
      _errorMessage = 'Error al generar contenido: $e';
      _isLoading = false;
      if (kDebugMode) {
        print('Error en generateContent: $e');
      }
      notifyListeners();
      return null;
    }
  }

  /// Analiza una descripción de transacción y extrae información estructurada
  /// 
  /// [description] - Descripción en lenguaje natural de la transacción
  /// Retorna un mapa con los datos de la transacción extraídos por la IA
  Future<Map<String, dynamic>?> analyzeTransaction(String description) async {
    if (_model == null) {
      _errorMessage = 'El modelo no ha sido inicializado. Llama a initializeGeminiModel() primero.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prompt = '''
Analiza la siguiente descripción de transacción financiera y extrae la información relevante.
Descripción: "$description"

Responde ÚNICAMENTE con un objeto JSON válido (sin markdown, sin bloques de código) con esta estructura exacta:
{
  "tipo": "ingreso" o "gasto",
  "monto": número decimal sin símbolo de moneda,
  "categoria": "nombre de categoría apropiada (ej: Alimentación, Transporte, Salario, etc.)",
  "descripcion": "descripción limpia y concisa",
  "fecha": "fecha en formato YYYY-MM-DD (usa la fecha actual si no se especifica)"
}

Reglas importantes:
- Si no puedes determinar algún campo, usa valores por defecto razonables
- El monto debe ser un número sin símbolos
- La fecha debe estar en formato ISO (YYYY-MM-DD)
- NO incluyas bloques de código markdown ni texto adicional, solo el JSON
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      _isLoading = false;
      
      if (response.text == null) {
        _errorMessage = 'La IA no generó ninguna respuesta';
        notifyListeners();
        return null;
      }

      // Limpiar la respuesta para obtener solo el JSON
      String jsonString = response.text!.trim();
      
      // Remover bloques de código markdown si existen
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*'), '');
      jsonString = jsonString.trim();
      
      if (kDebugMode) {
        print('Respuesta de la IA: $jsonString');
      }

      // Parsear el JSON
      final Map<String, dynamic> result = json.decode(jsonString);
      
      // Validar que tenga los campos requeridos
      if (!result.containsKey('tipo') || 
          !result.containsKey('monto') || 
          !result.containsKey('categoria')) {
        _errorMessage = 'La respuesta de la IA no contiene todos los campos requeridos';
        notifyListeners();
        return null;
      }

      notifyListeners();
      return result;
      
    } catch (e) {
      _errorMessage = 'Error al analizar transacción: $e';
      _isLoading = false;
      if (kDebugMode) {
        print('Error en analyzeTransaction: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      notifyListeners();
      return null;
    }
  }

  /// Procesa la descripción con la IA y guarda la transacción resultante en Firestore
  ///
  /// [idUsuario] - id del usuario que será guardado en el documento
  /// [description] - texto que se analizará con la IA
  /// Retorna true si se guardó correctamente, false si hubo un error
  Future<bool> processAndSaveDescription(String idUsuario, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final parsed = await analyzeTransaction(description);
      if (parsed == null) {
        _errorMessage = 'No se pudo parsear la transacción con la IA';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Normalizar campos
      final tipoRaw = parsed['tipo']?.toString().toLowerCase() ?? 'gasto';
      final montoRaw = parsed['monto'];
      double monto;
      if (montoRaw is num) {
        monto = montoRaw.toDouble();
      } else if (montoRaw is String) {
        monto = double.tryParse(montoRaw.replaceAll(RegExp(r'[^0-9\.,-]'), '').replaceAll(',', '.')) ?? 0.0;
      } else {
        monto = 0.0;
      }

      final categoria = parsed['categoria']?.toString() ?? '';
      final descripcion = parsed['descripcion']?.toString() ?? description;

      DateTime fecha;
      if (parsed.containsKey('fecha') && parsed['fecha'] != null && parsed['fecha'].toString().isNotEmpty) {
        fecha = DateTime.tryParse(parsed['fecha'].toString()) ?? DateTime.now();
      } else {
        fecha = DateTime.now();
      }

      final firestore = FirebaseFirestore.instance;

      if (tipoRaw == 'ingreso' || tipoRaw == 'income' || tipoRaw == 'entrada') {
        // Crear Ingreso con valores por defecto razonables
        final ingreso = Ingreso(
          id: UniqueKey().toString(),
          idUsuario: idUsuario,
          monto: monto,
          fecha: fecha,
          descripcion: descripcion,
          categoria: categoria,
          metodoPago: parsed['metodoPago']?.toString() ?? '',
          origen: parsed['origen']?.toString() ?? '',
        );

        await firestore.collection('ingresos').add(ingreso.toMap());
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Tratar como gasto / factura
        final factura = Factura(
          idUsuario: idUsuario,
          proveedor: parsed['proveedor']?.toString() ?? '',
          monto: monto,
          descripcion: descripcion,
          lugarLocal: parsed['lugarLocal']?.toString() ?? '',
          categoria: categoria,
        );

        await firestore.collection('facturas').add(factura.toMap());
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Error al procesar y guardar la transacción: $e';
      _isLoading = false;
      if (kDebugMode) print('processAndSaveDescription error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Guarda un mapa ya parseado (por ejemplo resultado de `analyzeTransaction`) en Firestore.
  /// Retorna true si guardó correctamente.
  Future<bool> saveParsedTransaction(Map<String, dynamic> parsed, String? idUsuario) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tipoRaw = parsed['tipo']?.toString().toLowerCase() ?? 'gasto';

      final montoRaw = parsed['monto'];
      double monto;
      if (montoRaw is num) {
        monto = montoRaw.toDouble();
      } else if (montoRaw is String) {
        monto = double.tryParse(montoRaw.replaceAll(RegExp(r'[^0-9\.,-]'), '').replaceAll(',', '.')) ?? 0.0;
      } else {
        monto = 0.0;
      }

      final categoria = parsed['categoria']?.toString() ?? '';
      final descripcion = parsed['descripcion']?.toString() ?? '';

      DateTime fecha;
      if (parsed.containsKey('fecha') && parsed['fecha'] != null && parsed['fecha'].toString().isNotEmpty) {
        fecha = DateTime.tryParse(parsed['fecha'].toString()) ?? DateTime.now();
      } else {
        fecha = DateTime.now();
      }

      final firestore = FirebaseFirestore.instance;

      // Determine effective user id: prefer authenticated user if available
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      String? effectiveUserId = idUsuario;
      if (currentUserId != null) {
        if (idUsuario == null || idUsuario.isEmpty) {
          effectiveUserId = currentUserId;
        } else if (idUsuario != currentUserId) {
          // Log mismatch and prefer authenticated user for security reasons
          if (kDebugMode) print('Warning: idUsuario passed ($idUsuario) does not match authenticated uid ($currentUserId). Using authenticated uid.');
          effectiveUserId = currentUserId;
        }
      }

      if (tipoRaw == 'ingreso' || tipoRaw == 'income' || tipoRaw == 'entrada') {
        final ingreso = Ingreso(
          id: UniqueKey().toString(),
          idUsuario: effectiveUserId ?? (idUsuario ?? ''),
          monto: monto,
          fecha: fecha,
          descripcion: descripcion,
          categoria: categoria,
          metodoPago: parsed['metodoPago']?.toString() ?? '',
          origen: parsed['origen']?.toString() ?? '',
        );

        // Build payload: keep ISO string for backwards compatibility, add fecha_ts Timestamp and userId/createdAt
        final payloadIngreso = {
          'id': ingreso.id,
          'idUsuario': ingreso.idUsuario,
          'userId': ingreso.idUsuario,
          'monto': ingreso.monto,
          'fecha': ingreso.fecha.toIso8601String(),
          'fecha_ts': Timestamp.fromDate(ingreso.fecha),
          'descripcion': ingreso.descripcion,
          'categoria': ingreso.categoria,
          'metodoPago': ingreso.metodoPago,
          'origen': ingreso.origen,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'ai',
        };

        try {
      final targetPath = effectiveUserId != null && effectiveUserId.isNotEmpty
        ? 'users/$effectiveUserId/ingresos'
        : 'ingresos';
          if (kDebugMode) {
            print('Attempting to save ingreso to $targetPath with payload: $payloadIngreso');
          }
          if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
            await firestore.collection('users').doc(effectiveUserId).collection('ingresos').add(payloadIngreso);
          } else {
            await firestore.collection('ingresos').add(payloadIngreso);
          }
        } on FirebaseException catch (fe) {
          // Si falla por reglas de seguridad u otros motivos, intentar fallback a colección top-level
          final attempted = effectiveUserId != null && effectiveUserId.isNotEmpty ? 'users/$effectiveUserId/ingresos' : 'ingresos';
          _errorMessage = 'FirebaseException al guardar ingreso en $attempted: ${fe.message}';
          if (kDebugMode) print('FirebaseException saving ingreso under user subcollection: ${fe.message}');
          try {
            if (kDebugMode) print('Attempting fallback save to ingresos as top-level with payload: $payloadIngreso');
            await firestore.collection('ingresos').add(payloadIngreso);
            _isLoading = false;
            notifyListeners();
            return true;
          } catch (e) {
            _errorMessage = 'No se pudo guardar el ingreso (fallback falló): $e';
            if (kDebugMode) print('Fallback failed saving ingreso: $e');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Gasto / factura
      final factura = Factura(
        idUsuario: effectiveUserId ?? (idUsuario ?? ''),
        proveedor: parsed['proveedor']?.toString() ?? '',
        monto: monto,
        descripcion: descripcion,
        lugarLocal: parsed['lugarLocal']?.toString() ?? '',
        categoria: categoria,
      );

      // Build factura payload similarly: keep ISO string and add timestamp + userId
      final payloadFactura = {
        'idUsuario': factura.idUsuario,
        'userId': factura.idUsuario,
        'proveedor': factura.proveedor,
        'monto': factura.monto,
        'descripcion': factura.descripcion,
        'lugarLocal': factura.lugarLocal,
        'categoria': factura.categoria,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'ai',
      };
      try {
    final targetPath = effectiveUserId != null && effectiveUserId.isNotEmpty
      ? 'users/$effectiveUserId/facturas'
      : 'facturas';
        if (kDebugMode) print('Attempting to save factura to $targetPath with payload: $payloadFactura');
        if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
          await firestore.collection('users').doc(effectiveUserId).collection('facturas').add(payloadFactura);
        } else {
          await firestore.collection('facturas').add(payloadFactura);
        }
      } on FirebaseException catch (fe) {
        final attempted = idUsuario != null && idUsuario.isNotEmpty ? 'users/$idUsuario/facturas' : 'facturas';
        _errorMessage = 'FirebaseException al guardar factura en $attempted: ${fe.message}';
        if (kDebugMode) print('FirebaseException saving factura under user subcollection: ${fe.message}');
        try {
          if (kDebugMode) print('Attempting fallback save to facturas as top-level with payload: $payloadFactura');
          await firestore.collection('facturas').add(payloadFactura);
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          _errorMessage = 'No se pudo guardar la factura (fallback falló): $e';
          if (kDebugMode) print('Fallback failed saving factura: $e');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar transacción parseada: $e';
      _isLoading = false;
      if (kDebugMode) print('saveParsedTransaction error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Genera sugerencias de categorías basadas en una descripción
  /// 
  /// [description] - Descripción de la transacción
  /// Retorna una lista de categorías sugeridas
  Future<List<String>?> suggestCategories(String description) async {
    if (_model == null) {
      _errorMessage = 'El modelo no ha sido inicializado';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prompt = '''
Basándote en esta descripción de transacción: "$description"

Sugiere 3 categorías apropiadas para clasificar esta transacción.
Responde ÚNICAMENTE con un array JSON de strings (sin markdown, sin bloques de código):
["Categoría1", "Categoría2", "Categoría3"]
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      _isLoading = false;
      
      if (response.text == null) {
        _errorMessage = 'La IA no generó ninguna respuesta';
        notifyListeners();
        return null;
      }

      // Limpiar la respuesta
      String jsonString = response.text!.trim();
      jsonString = jsonString.replaceAll(RegExp(r'```json\s*'), '');
      jsonString = jsonString.replaceAll(RegExp(r'```\s*'), '');
      jsonString = jsonString.trim();

      final List<dynamic> result = json.decode(jsonString);
      final categories = result.map((e) => e.toString()).toList();
      
      notifyListeners();
      return categories;
      
    } catch (e) {
      _errorMessage = 'Error al sugerir categorías: $e';
      _isLoading = false;
      if (kDebugMode) {
        print('Error en suggestCategories: $e');
      }
      notifyListeners();
      return null;
    }
  }

  /// Analiza una imagen (ruta de archivo) usando ML Kit OCR y luego procesa el texto con el modelo
  Future<Map<String, dynamic>?> analyzeImage(String imagePath) async {
    if (_model == null) {
      _errorMessage = 'El modelo no ha sido inicializado. Llama a initializeGeminiModel() primero.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final extracted = recognizedText.text.trim();
      if (kDebugMode) {
        print('OCR texto extraído: $extracted');
      }

      if (extracted.isEmpty) {
        _errorMessage = 'No se encontró texto en la imagen';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Reutilizar analyzeTransaction para parsear el texto extraído
      final result = await analyzeTransaction(extracted);

      _isLoading = false;
      return result;
    } catch (e) {
      _errorMessage = 'Error al procesar imagen: $e';
      _isLoading = false;
      if (kDebugMode) print('Error en analyzeImage: $e');
      notifyListeners();
      return null;
    }
  }

  /// Limpia el mensaje de error actual
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia el texto generado
  void clearGeneratedText() {
    _generatedText = null;
    notifyListeners();
  }

  /// Resetea el estado del ViewModel
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _generatedText = null;
    notifyListeners();
  }
}
