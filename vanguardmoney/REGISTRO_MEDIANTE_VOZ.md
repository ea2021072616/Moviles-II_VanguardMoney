# 🎤 Funcionalidad de Registro mediante Voz - Implementación Completa

## Resumen

Se implementó la funcionalidad completa para registrar **Ingresos y Egresos** mediante audio/voz usando Gemini AI. La IA detecta automáticamente el tipo de transacción y redirige a la vista correspondiente.

**Fecha**: 16 de octubre de 2025  
**Estado**: ✅ Implementado - Requiere agregar dependencias  
**Archivos creados**: 2 archivos nuevos

---

## 📁 Archivos Creados

### 1. **registrar_voz_viewmodel.dart** ✅
**Ubicación**: `lib/features/transactions/viewmodels/`

**Responsabilidades**:
- ✅ Inicializar modelo Gemini
- ✅ Grabar audio o cargar archivo
- ✅ Enviar audio a Gemini para análisis
- ✅ **Detectar automáticamente** si es ingreso o egreso
- ✅ Extraer todos los campos relevantes
- ✅ Gestionar estado de carga y errores

**Métodos principales**:
```dart
- initializeGeminiModel() // Inicializa Gemini
- analizarAudioYExtraerDatos(audioPath, idUsuario) // Analiza el audio
- setRecording(bool) // Marca si está grabando
- setAudioPath(String?) // Establece ruta del audio
- cambiarCategoria(String) // Cambia categoría sugerida
- limpiarDatos() // Limpia estado
```

**Campos del ViewModel**:
```dart
bool isLoading
bool isRecording
String? errorMessage
Map<String, dynamic>? datosExtraidos
String? categoriaSugerida
String? tipoTransaccion // 'ingreso' o 'egreso'
String? audioPath
```

---

### 2. **registrar_con_voz_screen.dart** ✅
**Ubicación**: `lib/features/transactions/views/`

**Responsabilidades**:
- ✅ Interfaz para grabar audio en tiempo real
- ✅ Interfaz para cargar archivo de audio
- ✅ Mostrar estado de grabación
- ✅ Analizar audio con IA
- ✅ Redirigir a `RegisterBillView` si es egreso
- ✅ Mostrar diálogo informativo si es ingreso

**Características UI**:
- 🎤 Botón para grabar audio
- 📁 Botón para cargar archivo
- 🔴 Indicador visual de grabación
- ✅ Tarjeta de audio listo
- 🤖 Botón "Analizar con IA"
- 💡 Tips para mejores resultados
- ⚡ Loading states

---

## 🔧 Dependencias Requeridas

### ⚠️ **IMPORTANTE: Agregar al `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # ... tus dependencias existentes ...
  
  # 🎤 Para grabar audio
  record: ^5.0.4
  
  # 📁 Para seleccionar archivos
  file_picker: ^6.1.1
  
  # 📂 Para obtener directorios
  path_provider: ^2.1.1
```

### Instalación

Después de agregar al `pubspec.yaml`, ejecuta:

```bash
flutter pub get
```

### Permisos Requeridos

#### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest ...>
    <!-- Permisos de audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <application ...>
        ...
    </application>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`):
```xml
<dict>
    ...
    <!-- Permisos de audio -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Necesitamos acceso al micrófono para grabar notas de voz de tus transacciones</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Necesitamos acceso para cargar archivos de audio</string>
</dict>
```

---

## 🤖 Lógica de Detección Automática

### Prompt de Gemini

El ViewModel envía un prompt inteligente que:

1. **Detecta el tipo** basándose en palabras clave:
   - **Ingreso**: "recibí", "me pagaron", "ingreso", "cobré", "ganancia", "salario", "venta"
   - **Egreso**: "pagué", "compré", "gasto", "factura", "compra", "gasté", "egreso"

2. **Extrae campos específicos** según el tipo:
   
   **Para Ingresos**:
   ```json
   {
     "tipo": "ingreso",
     "monto": "1500.00",
     "fecha": "2025-10-16",
     "descripcion": "Pago de freelance",
     "categoria": "Salario",
     "metodoPago": "transferencia",
     "origen": "cliente XYZ"
   }
   ```
   
   **Para Egresos**:
   ```json
   {
     "tipo": "egreso",
     "invoiceNumber": "VOZ-2025-10-16-001",
     "invoiceDate": "2025-10-16",
     "totalAmount": "847.00",
     "supplierName": "Walmart",
     "supplierTaxId": "",
     "description": "Compra de supermercado",
     "taxAmount": "0.0",
     "lugarLocal": "Walmart Centro",
     "categoria": "Comida"
   }
   ```

---

## 🔄 Flujo de Trabajo

### Flujo Completo

```
1. Usuario abre "Registrar con Voz"
   ↓
2. Opciones:
   A) Grabar nuevo audio
   B) Cargar archivo de audio
   ↓
3. Usuario describe transacción
   Ejemplo: "Pagué 500 pesos en Walmart por comida"
   ↓
4. Usuario presiona "Analizar con IA"
   ↓
5. Gemini analiza el audio
   ↓
6. Gemini determina:
   - Tipo: "egreso"
   - Monto: 500
   - Proveedor: "Walmart"
   - Descripción: "comida"
   - Categoría: "Comida"
   ↓
7. Redirección automática:
   - Si es EGRESO → RegisterBillView (con datos prellenados)
   - Si es INGRESO → Diálogo informativo (por implementar)
   ↓
8. Usuario revisa/edita datos
   ↓
9. Usuario guarda en Firebase
```

---

## 📊 Mapeo de Datos

### Egreso (Audio → RegisterBillView)

| Campo Audio | Campo Factura | Tipo |
|------------|---------------|------|
| `tipo` | - | Detección |
| `totalAmount` | `totalAmountController` | TextController |
| `supplierName` | `supplierNameController` | TextController |
| `description` | `descripcionController` | TextController |
| `lugarLocal` | `lugarLocalController` | TextController |
| `categoria` | `categoriaSeleccionada` | String |
| `invoiceNumber` | `invoiceNumberController` | TextController |
| `invoiceDate` | `invoiceDate` | DateTime |
| `supplierTaxId` | `supplierTaxIdController` | TextController |
| `taxAmount` | `taxAmountController` | TextController |
| `audioPath` | `scanImagePath` | String (audio en vez de imagen) |

### Ingreso (Audio → RegisterIngresoView)

**⚠️ Pendiente**: `RegisterIngresoView` no acepta datos iniciales aún.

**Solución temporal**: Mostrar diálogo con los datos extraídos.

**Campos a implementar**:
| Campo Audio | Campo Ingreso | Tipo |
|------------|---------------|------|
| `monto` | `montoController` | TextController |
| `descripcion` | `descripcionController` | TextController |
| `categoria` | `categoriaSeleccionada` | String |
| `metodoPago` | `metodoPagoController` | TextController |
| `origen` | `origenController` | TextController |
| `fecha` | `fecha` | DateTime |

---

## 🎯 Ejemplos de Uso

### Ejemplo 1: Egreso/Gasto
**Audio del usuario**:
> "Hoy pagué 1,200 pesos en la gasolinera Shell por combustible"

**Resultado detectado**:
```json
{
  "tipo": "egreso",
  "totalAmount": "1200.00",
  "supplierName": "Shell",
  "description": "combustible",
  "lugarLocal": "gasolinera Shell",
  "categoria": "Transporte",
  "invoiceNumber": "VOZ-2025-10-16-001",
  "invoiceDate": "2025-10-16"
}
```

**Acción**: Redirige a `RegisterBillView` con campos prellenados.

---

### Ejemplo 2: Ingreso
**Audio del usuario**:
> "Recibí un pago de 5,000 pesos por transferencia de mi cliente por servicios de diseño"

**Resultado detectado**:
```json
{
  "tipo": "ingreso",
  "monto": "5000.00",
  "descripcion": "servicios de diseño",
  "categoria": "Freelance",
  "metodoPago": "transferencia",
  "origen": "cliente"
}
```

**Acción**: Muestra diálogo informativo (por implementar redirección a RegisterIngresoView).

---

### Ejemplo 3: Egreso con detalles
**Audio del usuario**:
> "Compré en Walmart 850 pesos de comida para la semana, incluye frutas, verduras y carne"

**Resultado detectado**:
```json
{
  "tipo": "egreso",
  "totalAmount": "850.00",
  "supplierName": "Walmart",
  "description": "frutas, verduras y carne",
  "lugarLocal": "Walmart",
  "categoria": "Comida",
  "invoiceNumber": "VOZ-2025-10-16-002",
  "invoiceDate": "2025-10-16"
}
```

---

## 🔧 Mejoras Pendientes

### 1. **Agregar soporte de datos iniciales a RegisterIngresoView** 🔴 CRÍTICO

**Archivo**: `register_ingreso_view.dart`

**Cambios necesarios**:

```dart
class RegisterIngresoView extends ConsumerStatefulWidget {
  final String idUsuario;
  final Map<String, dynamic>? datosIniciales; // ← Agregar esto
  
  const RegisterIngresoView({
    Key? key, 
    required this.idUsuario,
    this.datosIniciales, // ← Agregar esto
  }) : super(key: key);
  
  // ...
}

class _RegisterIngresoViewState extends ConsumerState<RegisterIngresoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriaIngresoViewModelProvider)
          .cargarCategorias(widget.idUsuario, TipoCategoria.ingreso);
      
      // ← Agregar esto
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
  // ...
}
```

### 2. **Actualizar registrar_con_voz_screen.dart** 🔴 CRÍTICO

Reemplazar el método `_mostrarDialogoIngresoNoSoportado` con navegación directa:

```dart
Future<void> _analyzeAudio() async {
  // ... código existente ...
  
  if (viewModel.datosExtraidos != null && viewModel.tipoTransaccion != null) {
    if (viewModel.tipoTransaccion == 'egreso') {
      // ... código existente para egreso ...
    } else if (viewModel.tipoTransaccion == 'ingreso') {
      // ← Cambiar esto
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
  }
}
```

### 3. **Agregar badge "VOZ" en las vistas** 🟡 OPCIONAL

Similar al badge "IA" existente, agregar uno para "VOZ":

```dart
if (widget.datosIniciales != null) ...[
  const SizedBox(width: 8),
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mic, size: 16),
        SizedBox(width: 4),
        Text('VOZ', style: TextStyle(fontSize: 12)),
      ],
    ),
  ),
],
```

### 4. **Soportar más formatos de audio** 🟢 BAJA PRIORIDAD

Actualmente soporta: `.m4a`, `.mp3`, `.wav`, `.aac`

Para agregar más formatos, actualizar el mime type en el ViewModel:

```dart
InlineDataPart('audio/mp3', audioBytes), // Cambiar según formato
```

---

## 📱 Integración al Menú Principal

### Agregar botón en el home

```dart
// En home_view.dart o donde tengas el menú
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => RegistrarMedianteVozViewModel(),
          child: RegistrarConVozScreen(
            idUsuario: currentUserId,
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
  ),
)
```

---

## 🧪 Testing

### Casos de Prueba

#### ✅ Caso 1: Egreso con grabación
```
1. Abrir "Registrar con Voz"
2. Presionar "Grabar Audio"
3. Decir: "Pagué 250 pesos en Starbucks por café"
4. Detener grabación
5. Presionar "Analizar con IA"
6. Verificar redirección a RegisterBillView
7. Verificar campos prellenados:
   - Monto: 250
   - Proveedor: Starbucks
   - Descripción: café
   - Categoría: Comida
```

#### ✅ Caso 2: Ingreso con archivo
```
1. Abrir "Registrar con Voz"
2. Presionar "Cargar Archivo de Audio"
3. Seleccionar audio que dice: "Recibí 3000 por transferencia de freelance"
4. Presionar "Analizar con IA"
5. Verificar diálogo informativo con datos extraídos
6. (Después de implementar) Verificar redirección a RegisterIngresoView
```

#### ✅ Caso 3: Audio ambiguo
```
1. Grabar: "500 pesos de la tienda"
2. Analizar
3. Verificar que Gemini infiera correctamente como egreso
4. Verificar que complete campos faltantes con valores por defecto
```

---

## 🎨 Diseño de la UI

### Paleta de Colores
- **Principal**: Purple (`Colors.purple`)
- **Grabando**: Red (`Colors.red`)
- **Listo**: Green (`Colors.green`)
- **Fondo**: Purple[50] con borde Purple[200]

### Estados Visuales
1. **Inicial**: Botón grande "Grabar Audio" + "Cargar Archivo"
2. **Grabando**: Botón rojo "Detener" + indicador pulsante
3. **Audio Listo**: Tarjeta verde + botones "Analizar" y "Eliminar"
4. **Analizando**: Spinner en botón + texto "Analizando..."

---

## 📊 Comparativa con Otros Métodos

| Característica | Manual | IA Imagen | **IA Voz** |
|---------------|--------|-----------|-----------|
| **Velocidad** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Precisión** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Comodidad** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Campos completos** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Ideal para** | Datos completos | Facturas físicas | **Registro rápido** |

---

## 🚀 Estado Final

### ✅ IMPLEMENTADO

**Archivos creados**:
- ✅ `registrar_voz_viewmodel.dart` - Lógica completa
- ✅ `registrar_con_voz_screen.dart` - UI completa

**Funcionalidades**:
- ✅ Grabar audio en tiempo real
- ✅ Cargar archivo de audio
- ✅ Analizar con Gemini
- ✅ Detectar tipo automáticamente
- ✅ Extraer campos relevantes
- ✅ Redirigir a RegisterBillView (egresos)
- ✅ Manejo de errores

**Pendiente**:
- 🔴 Agregar dependencias al `pubspec.yaml`
- 🔴 Agregar permisos en AndroidManifest.xml y Info.plist
- 🔴 Implementar soporte de datos iniciales en RegisterIngresoView
- 🔴 Actualizar redirección para ingresos
- 🟡 Agregar badge "VOZ" en vistas
- 🟢 Testing en dispositivos reales

---

## 📚 Documentos Relacionados

1. ELIMINACION_CAMPOS_INNECESARIOS.md - Modelo de Factura actualizado
2. ACTUALIZACION_CAMPOS_FACTURA.md - Estructura de datos
3. **REGISTRO_MEDIANTE_VOZ.md** ← Este documento

---

**Versión**: 1.0  
**Estado**: ✅ Código completo - Requiere dependencias  
**Próximo paso**: Agregar dependencias y probar en dispositivo real
