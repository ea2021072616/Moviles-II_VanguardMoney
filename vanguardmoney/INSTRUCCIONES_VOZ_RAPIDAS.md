# ⚡ INSTRUCCIONES RÁPIDAS - Registro mediante Voz

## 🎯 ¿Qué hace esta funcionalidad?

Permite registrar **Ingresos y Egresos** hablando a través del micrófono o cargando un audio. La IA detecta automáticamente si es un ingreso o egreso y extrae todos los datos.

---

## 📦 Paso 1: Agregar Dependencias

### Abre `pubspec.yaml` y agrega estas líneas:

```yaml
dependencies:
  # ... tus dependencias existentes ...
  
  # 🎤 Para registro mediante voz
  record: ^5.0.4
  file_picker: ^6.1.1
  path_provider: ^2.1.1
```

### Luego ejecuta:

```bash
flutter pub get
```

---

## 🔐 Paso 2: Agregar Permisos

### Android

Abre: `android/app/src/main/AndroidManifest.xml`

Agrega dentro de `<manifest>` (antes de `<application>`):

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Abre: `ios/Runner/Info.plist`

Agrega dentro de `<dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para grabar tus transacciones por voz</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Para cargar archivos de audio</string>
```

---

## 🎨 Paso 3: Agregar al Menú

### Opción A: Agregar botón en el home

Donde tengas tu menú principal, agrega:

```dart
import 'package:provider/provider.dart';
import 'package:your_app/features/transactions/viewmodels/registrar_voz_viewmodel.dart';
import 'package:your_app/features/transactions/views/registrar_con_voz_screen.dart';

// ...

ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => RegistrarMedianteVozViewModel(),
          child: RegistrarConVozScreen(
            idUsuario: 'tu_id_usuario', // Cambia esto
          ),
        ),
      ),
    );
  },
  icon: const Icon(Icons.mic),
  label: const Text('Registrar con Voz'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

---

## 🔧 Paso 4 (OPCIONAL): Soporte para Ingresos

**Por defecto**, solo funcionan los **EGRESOS** automáticamente.

Para que los **INGRESOS** también funcionen, necesitas modificar `register_ingreso_view.dart`:

### Cambio 1: Agregar parámetro `datosIniciales`

```dart
class RegisterIngresoView extends ConsumerStatefulWidget {
  final String idUsuario;
  final Map<String, dynamic>? datosIniciales; // ← AGREGAR
  
  const RegisterIngresoView({
    Key? key,
    required this.idUsuario,
    this.datosIniciales, // ← AGREGAR
  }) : super(key: key);
  
  // ...
}
```

### Cambio 2: Prellenar campos en `initState()`

Dentro de `_RegisterIngresoViewState`, en el método `initState()`, agrega después de cargar categorías:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(categoriaIngresoViewModelProvider)
        .cargarCategorias(widget.idUsuario, TipoCategoria.ingreso);
    
    // ← AGREGAR ESTO
    if (widget.datosIniciales != null) {
      final viewModel = ref.read(registrarIngresoViewModelProvider);
      final datos = widget.datosIniciales!;
      
      viewModel.montoController.text = datos['monto']?.toString() ?? '';
      viewModel.descripcionController.text = datos['descripcion']?.toString() ?? '';
      viewModel.metodoPagoController.text = datos['metodoPago']?.toString() ?? '';
      viewModel.origenController.text = datos['origen']?.toString() ?? '';
      
      if (datos['fecha'] != null) {
        try {
          viewModel.setFecha(DateTime.parse(datos['fecha']));
        } catch (e) {
          viewModel.setFecha(DateTime.now());
        }
      }
      
      final categoria = datos['categoria']?.toString();
      if (categoria != null && categoria.isNotEmpty) {
        viewModel.setCategoria(categoria);
      }
    }
  });
}
```

### Cambio 3: Actualizar `registrar_con_voz_screen.dart`

Busca el método `_analyzeAudio()` y reemplaza la sección de ingresos:

**ANTES:**
```dart
} else if (viewModel.tipoTransaccion == 'ingreso') {
  _mostrarDialogoIngresoNoSoportado(viewModel.datosExtraidos!);
}
```

**DESPUÉS:**
```dart
} else if (viewModel.tipoTransaccion == 'ingreso') {
  final datosParaIngreso = {
    'monto': viewModel.datosExtraidos!['monto'],
    'fecha': viewModel.datosExtraidos!['fecha'],
    'descripcion': viewModel.datosExtraidos!['descripcion'],
    'categoria': viewModel.datosExtraidos!['categoria'],
    'metodoPago': viewModel.datosExtraidos!['metodoPago'],
    'origen': viewModel.datosExtraidos!['origen'],
  };

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegisterIngresoView(
        idUsuario: idUsuario,
        datosIniciales: datosParaIngreso,
      ),
    ),
  );
}
```

---

## 📱 Cómo Usar

### 1. **Grabar Audio**
- Presiona "Grabar Audio"
- Di: "Pagué 500 pesos en Walmart por comida"
- Presiona "Detener Grabación"
- Presiona "Analizar con IA"

### 2. **Cargar Archivo**
- Presiona "Cargar Archivo de Audio"
- Selecciona un archivo MP3/M4A
- Presiona "Analizar con IA"

### 3. **Resultado**
- Si es **EGRESO**: Abre formulario con datos prellenados
- Si es **INGRESO**: Muestra diálogo (o abre formulario si implementaste el paso 4)

---

## ✅ Verificación

Después de seguir los pasos:

1. ✅ Ejecuta `flutter pub get`
2. ✅ Verifica que no haya errores de compilación
3. ✅ Prueba en un **dispositivo real** (no funciona en emulador)
4. ✅ Da permisos de micrófono cuando los solicite
5. ✅ Graba un audio de prueba
6. ✅ Verifica que funcione la detección automática

---

## 🐛 Problemas Comunes

### Error: "No se puede grabar"
**Solución**: Asegúrate de dar permisos de micrófono.

### Error: "Packages not found"
**Solución**: Ejecuta `flutter pub get` y reinicia VS Code.

### No detecta el tipo correctamente
**Solución**: Habla más claro y menciona explícitamente "pagué" o "recibí".

### No funciona en emulador
**Solución**: Usa un dispositivo físico, los emuladores tienen problemas con audio.

---

## 📚 Más Información

Lee `REGISTRO_MEDIANTE_VOZ.md` para documentación completa.

---

**¡Listo para usar! 🎉**
