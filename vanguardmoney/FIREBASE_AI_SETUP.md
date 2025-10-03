# Integración de Firebase AI (Gemini) en VanguardMoney

## 📋 Resumen

Este proyecto ahora incluye integración con **Firebase AI** (anteriormente Firebase Vertex AI) para usar el modelo **Gemini** de Google para análisis inteligente de transacciones financieras.

## 🚀 Configuración Inicial

### Paso 1: Archivos de Configuración de Firebase

1. **Para Android:**
   - Descarga el archivo `google-services.json` desde la consola de Firebase
   - Colócalo en: `android/app/google-services.json`
   - ✅ Ya existe en tu proyecto

2. **Para iOS:**
   - Descarga el archivo `GoogleService-Info.plist` desde la consola de Firebase
   - Colócalo en: `ios/Runner/GoogleService-Info.plist`

### Paso 2: Dependencias Instaladas

Las siguientes dependencias ya fueron agregadas a `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_ai: ^2.3.0  # SDK de Firebase AI para Gemini
  provider: ^6.1.5+1
```

✅ Ejecuta `flutter pub get` si aún no lo has hecho.

## 📝 Uso del ViewModel

### Inicialización

El `RegistrarMedianteIAViewModel` debe ser inicializado antes de usarse:

```dart
import 'package:provider/provider.dart';
import 'package:vanguardmoney/features/transactions/viewmodels/registrar_mediante_IA_viewmode.dart';

// En tu widget
final viewModel = Provider.of<RegistrarMedianteIAViewModel>(context, listen: false);
await viewModel.initializeGeminiModel();
```

### Análisis de Transacciones

```dart
// Analizar una descripción de transacción en lenguaje natural
final result = await viewModel.analyzeTransaction(
  'Pagué 25.50 por almorzar en un restaurante'
);

if (result != null) {
  print('Tipo: ${result['tipo']}');        // "gasto"
  print('Monto: ${result['monto']}');      // 25.50
  print('Categoría: ${result['categoria']}'); // "Alimentación"
  print('Descripción: ${result['descripcion']}');
  print('Fecha: ${result['fecha']}');      // "2025-10-02"
}
```

### Generar Contenido de Texto

```dart
// Generar texto usando Gemini
final text = await viewModel.generateContent(
  'Escribe un consejo de ahorro financiero breve'
);

if (text != null) {
  print('Respuesta: $text');
}
```

### Sugerir Categorías

```dart
// Obtener sugerencias de categorías
final categories = await viewModel.suggestCategories(
  'Compré gasolina para mi auto'
);

if (categories != null) {
  print('Categorías sugeridas: $categories');
  // ["Transporte", "Vehículo", "Combustible"]
}
```

## 🎨 Pantalla de Ejemplo

Se incluye una pantalla de ejemplo en:
```
lib/features/transactions/views/registrar_con_ia_screen.dart
```

Para usarla, agrégala a tu navegación o main:

```dart
import 'package:vanguardmoney/features/transactions/views/registrar_con_ia_screen.dart';
import 'package:vanguardmoney/features/transactions/viewmodels/registrar_mediante_IA_viewmode.dart';
import 'package:provider/provider.dart';

// En tu app
MaterialApp(
  home: ChangeNotifierProvider(
    create: (_) => RegistrarMedianteIAViewModel(),
    child: const RegistrarConIAScreen(),
  ),
)
```

## 🔑 Características del ViewModel

### Propiedades

- `isLoading` - Indica si hay una operación en curso
- `errorMessage` - Mensaje de error si algo falló
- `generatedText` - Último texto generado por la IA

### Métodos Principales

1. **`initializeGeminiModel()`**
   - Inicializa el modelo Gemini
   - Debe llamarse antes de cualquier otra operación
   - No requiere API key (usa Firebase Authentication)

2. **`analyzeTransaction(String description)`**
   - Analiza una descripción de transacción
   - Retorna un `Map<String, dynamic>` con los datos estructurados
   - Campos: `tipo`, `monto`, `categoria`, `descripcion`, `fecha`

3. **`generateContent(String prompt)`**
   - Genera texto basado en un prompt
   - Retorna un `String` con la respuesta de Gemini

4. **`suggestCategories(String description)`**
   - Sugiere categorías apropiadas
   - Retorna una `List<String>` con 3 sugerencias

5. **`clearError()`** - Limpia mensajes de error
6. **`clearGeneratedText()`** - Limpia texto generado
7. **`reset()`** - Resetea todo el estado

## ⚠️ Requisitos Importantes

1. **Firebase debe estar inicializado** en tu `main.dart`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(const MyApp());
   }
   ```

2. **El proyecto debe estar configurado en Firebase Console**
   - Ve a [console.firebase.google.com](https://console.firebase.google.com)
   - Asegúrate de que Firebase AI esté habilitado para tu proyecto

3. **Internet Connection**
   - Firebase AI requiere conexión a internet
   - Maneja errores de red apropiadamente

## 🔧 Solución de Problemas

### Error: "El modelo no ha sido inicializado"
```dart
// Asegúrate de llamar esto primero:
await viewModel.initializeGeminiModel();
```

### Error al parsear JSON
El modelo intenta devolver JSON limpio, pero a veces incluye markdown. El ViewModel ya maneja esto automáticamente.

### Respuestas inconsistentes
El modelo Gemini es no-determinístico. Para resultados más consistentes, puedes:
- Hacer el prompt más específico
- Usar ejemplos en el prompt
- Validar y sanitizar las respuestas

## 📚 Recursos

- [Documentación de Firebase AI](https://firebase.google.com/docs/vertex-ai)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)

## 🎯 Ejemplo Completo

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanguardmoney/features/transactions/viewmodels/registrar_mediante_IA_viewmode.dart';

class MyTransactionScreen extends StatefulWidget {
  const MyTransactionScreen({super.key});

  @override
  State<MyTransactionScreen> createState() => _MyTransactionScreenState();
}

class _MyTransactionScreenState extends State<MyTransactionScreen> {
  late RegistrarMedianteIAViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegistrarMedianteIAViewModel();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    await _viewModel.initializeGeminiModel();
  }

  Future<void> _analyzeTransaction(String description) async {
    final result = await _viewModel.analyzeTransaction(description);
    
    if (result != null) {
      // Usa los datos extraídos
      final tipo = result['tipo'];
      final monto = result['monto'];
      final categoria = result['categoria'];
      
      // Crear transacción en tu base de datos
      // ...
    } else if (_viewModel.errorMessage != null) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Registrar Transacción')),
        body: Consumer<RegistrarMedianteIAViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                if (viewModel.isLoading)
                  const CircularProgressIndicator(),
                // Tu UI aquí
              ],
            );
          },
        ),
      ),
    );
  }
}
```

## ✅ Estado de la Implementación

- ✅ Dependencias instaladas
- ✅ ViewModel implementado
- ✅ Pantalla de ejemplo creada
- ✅ Firebase inicializado en main.dart
- ⚠️ Archivos de configuración (verifica `google-services.json` y `GoogleService-Info.plist`)
- 🔲 Habilitar Firebase AI en Firebase Console (si aún no lo has hecho)

---

**Nota:** Firebase AI usa el modelo Gemini de Google, que es gratis hasta cierto límite de uso. Revisa la [página de precios de Firebase](https://firebase.google.com/pricing) para más información.
