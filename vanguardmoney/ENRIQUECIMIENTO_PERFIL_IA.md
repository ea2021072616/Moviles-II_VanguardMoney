# 🎯 Enriquecimiento del Perfil de Usuario para Análisis IA Personalizado

## 📋 Resumen

Se agregaron **campos demográficos** al perfil de usuario para que la IA (Gemini 2.0) genere **análisis financieros más personalizados y contextualizados**.

---

## 🆕 Nuevos Campos Demográficos

### 1. **Estado Civil** 
- **Tipo:** `String?` (opcional)
- **Opciones:** 
  - Soltero/a
  - Casado/a
  - Divorciado/a
  - Viudo/a
  - Unión Libre
- **UI:** ChoiceChips
- **Uso en IA:** Ayuda a personalizar recomendaciones de ahorro y gasto según responsabilidades familiares

### 2. **¿Tienes Hijos?**
- **Tipo:** `bool?` (opcional)
- **Opciones:** Sí / No
- **UI:** ChoiceChips con iconos (✓ / ✗)
- **Uso en IA:** Influye en recomendaciones de educación, ahorro a largo plazo, seguros

### 3. **Número de Dependientes Económicos**
- **Tipo:** `int?` (opcional)
- **Rango:** 0-99
- **UI:** TextField numérico
- **Descripción:** Personas que dependen económicamente del usuario (hijos, padres, etc.)
- **Uso en IA:** Calcula carga financiera y ajusta expectativas de ahorro

### 4. **Nivel de Educación**
- **Tipo:** `String?` (opcional)
- **Opciones:**
  - Primaria
  - Secundaria
  - Técnico
  - Universitario
  - Posgrado
- **UI:** ChoiceChips
- **Uso en IA:** Contextualiza capacidad de ingresos y oportunidades de mejora

### 5. **Objetivos Financieros**
- **Tipo:** `List<String>?` (opcional, multi-selección)
- **Opciones:**
  - 💰 Ahorro
  - 📈 Inversión
  - 💳 Pagar Deudas
  - 🏠 Comprar Vivienda
  - 🎓 Educación
  - 👴 Retiro
  - ✈️ Viajes
  - 🏥 Emergencias
- **UI:** FilterChips con iconos
- **Uso en IA:** Alinea las recomendaciones con las metas personales del usuario

---

## 📊 Archivos Modificados

### **1. Modelos de Datos**
```
lib/features/auth/models/
├── user_profile_model.dart          ✅ Agregados 5 nuevos campos
└── edit_profile_model.dart          ✅ Agregados 5 nuevos campos + métodos copyWith/toMap
```

**Cambios en `UserProfileModel`:**
- ✅ Agregados campos: `estadoCivil`, `numeroDependientes`, `tieneHijos`, `nivelEducacion`, `objetivosFinancieros`
- ✅ Actualizado `fromMap()` para deserializar nuevos campos
- ✅ Actualizado `toMap()` para serializar nuevos campos
- ✅ Actualizado `copyWith()` para incluir nuevos campos
- ⚠️ Removido `const` del constructor (necesario para campos opcionales)

### **2. ViewModels**
```
lib/features/auth/viewmodels/
└── edit_profile_viewmodel.dart      ✅ Agregados 7 métodos nuevos
```

**Nuevos métodos:**
```dart
updateEstadoCivil(String?)
updateNumeroDependientes(int?)
updateNumeroDependientesFromString(String)
updateTieneHijos(bool?)
updateNivelEducacion(String?)
updateObjetivosFinancieros(List<String>?)
toggleObjetivoFinanciero(String)      // Para multi-selección
```

### **3. Vistas (UI)**
```
lib/features/auth/views/
└── edit_profile_page.dart           ✅ Nueva sección demográfica
```

**Nuevos widgets creados:**
- `_buildDemographicSection()` - Sección completa
- `_buildEstadoCivilField()` - ChoiceChips para estado civil
- `_buildTieneHijosField()` - Sí/No con iconos
- `_buildNumeroDependientesField()` - TextField numérico
- `_buildNivelEducacionField()` - ChoiceChips para educación
- `_buildObjetivosFinancierosField()` - FilterChips multi-selección

**Diseño:**
- 📌 Título de sección con icono `people_outline` en azul
- 📌 Descripción: "Ayúdanos a personalizar tu análisis financiero con IA"
- 📌 Todos los campos son **OPCIONALES** (no bloquean guardado)
- 📌 Chips con colores temáticos (`blueClassic`, `greenJade`)

### **4. Servicios de IA**
```
lib/features/analysis/services/
└── financial_analysis_service.dart  ✅ Integración de perfil en prompts
```

**Cambios clave:**

1. **Nuevo método:**
```dart
Future<Map<String, dynamic>?> _getUserProfile(String userId)
```
- Obtiene datos del usuario desde Firestore `/users/{userId}`

2. **Método actualizado:**
```dart
Future<FinancialAnalysisModel> analyzeFinances({
  required String userId,
  required AnalysisPeriod period,
}) async {
  // 🆕 Obtiene perfil del usuario
  final userProfile = await _getUserProfile(userId);
  
  // Pasa perfil a generación de recomendaciones
  final recommendations = await _generateRecommendations(
    data, summary, categoryInsights, patterns, userProfile
  );
  
  // Pasa perfil a texto explicativo
  final aiText = await _generateExplanationText(
    summary, categoryInsights, patterns, recommendations, userProfile
  );
}
```

3. **Prompt enriquecido para Gemini:**

**ANTES:**
```
📊 RESUMEN FINANCIERO:
- Ingresos: $X
- Gastos: $Y
...
```

**AHORA:**
```
👤 PERFIL DEL USUARIO:
- Edad: 28 años
- Ocupación: Ingeniero
- Estado civil: Casado/a
- Tiene hijos: Sí
- Dependientes económicos: 3
- Nivel educativo: Universitario
- Ingreso mensual aprox: $3500
- Objetivos financieros: Ahorro, Comprar Vivienda, Educación

📊 RESUMEN FINANCIERO:
- Ingresos: $X
- Gastos: $Y
...
```

**Resultado:** La IA genera recomendaciones **personalizadas** como:
- 👨‍👩‍👧‍👦 "Con 3 dependientes, considera un fondo de emergencia de 6 meses"
- 🎓 "Abre una cuenta de ahorro educativo para tus hijos"
- 🏠 "Tu objetivo de vivienda requiere ahorrar $500/mes durante 3 años"

---

## 🧪 Cómo Probar

### 1. **Actualizar Perfil**
```bash
# Ejecutar app
flutter run

# Navegar a:
Perfil → Editar Perfil → Sección "Información Demográfica"
```

### 2. **Llenar Datos Demográficos**
- Selecciona tu estado civil
- Indica si tienes hijos
- Ingresa número de dependientes
- Selecciona nivel educativo
- Marca tus objetivos financieros (multi-selección)

### 3. **Guardar y Verificar Firestore**
```javascript
// Firebase Console → Firestore → /users/{userId}
{
  "username": "Juan Pérez",
  "edad": 28,
  "estadoCivil": "Casado/a",        // 🆕
  "tieneHijos": true,                // 🆕
  "numeroDependientes": 3,           // 🆕
  "nivelEducacion": "Universitario", // 🆕
  "objetivosFinancieros": [          // 🆕
    "Ahorro",
    "Comprar Vivienda",
    "Educación"
  ]
}
```

### 4. **Ejecutar Análisis Financiero**
```bash
# Navegar a:
Tab de Análisis → Botón "Analizar Finanzas"
```

**Verificar que:**
- ✅ El prompt incluye sección "PERFIL DEL USUARIO"
- ✅ Las recomendaciones son personalizadas
- ✅ El texto narrativo menciona contexto familiar/educativo

---

## 📝 Ejemplo de Prompt Real

```
Eres un asesor financiero personal experto. Analiza estos datos financieros y genera exactamente 5 recomendaciones específicas y accionables:

👤 PERFIL DEL USUARIO:
- Edad: 32 años
- Ocupación: Diseñadora Gráfica
- Estado civil: Unión Libre
- Tiene hijos: No
- Dependientes económicos: 1
- Nivel educativo: Universitario
- Ingreso mensual aprox: $2800
- Objetivos financieros: Ahorro, Inversión, Retiro

📊 RESUMEN FINANCIERO:
- Ingresos totales: $2800.00
- Gastos totales: $2450.00
- Balance: $350.00
- Tasa de ahorro: 12.5%
- Gasto promedio: $122.50

📈 TOP 5 CATEGORÍAS DE GASTO:
1. Alimentación: $680.00 (27.8%)
2. Transporte: $520.00 (21.2%)
3. Entretenimiento: $380.00 (15.5%)
4. Salud: $290.00 (11.8%)
5. Educación: $245.00 (10.0%)

🔍 PATRONES DETECTADOS:
- No se detectaron patrones inusuales

INSTRUCCIONES:
Genera EXACTAMENTE 5 recomendaciones PERSONALIZADAS considerando el perfil demográfico del usuario.
Formato JSON:
[...]
```

---

## 🎯 Beneficios

### Para el Usuario:
- ✅ Recomendaciones **alineadas con su situación real**
- ✅ Insights considerando **responsabilidades familiares**
- ✅ Consejos adaptados a **objetivos personales**
- ✅ Análisis más **empático y contextualizado**

### Para la IA:
- ✅ Contexto más rico para generar mejores respuestas
- ✅ Capacidad de priorizar recomendaciones
- ✅ Evita sugerencias genéricas o inapropiadas
- ✅ Puede calcular metas más realistas

### Ejemplos de Mejoras:

**SIN PERFIL:**
> "Reduce tus gastos en entretenimiento un 20%"

**CON PERFIL (32 años, sin hijos, objetivos: ahorro+inversión):**
> "Con tu tasa de ahorro actual (12.5%), tardarás 8 años en alcanzar un fondo de emergencia ideal. Como no tienes dependientes, podrías:
> 1. Reducir entretenimiento de $380 a $280 (-$100/mes)
> 2. Invertir ese $100 en un ETF de bajo riesgo
> 3. En 5 años tendrás $7,500 + rendimientos (~8% anual)"

---

## ✅ Confirmación de Integración

### **Backend (Firestore):**
- ✅ Nuevos campos se guardan correctamente en `/users/{userId}`
- ✅ Campos opcionales no bloquean registro/edición
- ✅ Listas (`objetivosFinancieros`) se serializan como arrays

### **Frontend (UI):**
- ✅ Sección demográfica aparece en edición de perfil
- ✅ Todos los widgets funcionan correctamente
- ✅ Validaciones permiten campos vacíos
- ✅ Guardado exitoso muestra SnackBar verde

### **IA (Gemini):**
- ✅ `_getUserProfile()` obtiene datos de Firestore
- ✅ Prompt incluye sección "PERFIL DEL USUARIO"
- ✅ Solo muestra campos que tienen valor (no muestra nulls)
- ✅ Recomendaciones y texto narrativo usan contexto demográfico

---

## 🚀 Próximos Pasos (Opcionales)

### Nivel 1: Análisis Básico
- [x] Agregar campos demográficos
- [x] Integrar en prompts de IA
- [x] UI para captura de datos

### Nivel 2: Análisis Avanzado (Futuro)
- [ ] **Scoring de salud financiera** basado en perfil
  - Ejemplo: "Para tu edad (32) y dependientes (3), tu tasa de ahorro debería ser >20%"
- [ ] **Comparación con promedios** de usuarios similares
  - "Usuarios de tu edad gastan 15% menos en entretenimiento"
- [ ] **Alertas predictivas**
  - "Con tus ingresos actuales y 3 dependientes, riesgo de déficit en 6 meses"

### Nivel 3: IA Conversacional (Futuro)
- [ ] Chat con IA que recuerda contexto del perfil
- [ ] Preguntas de seguimiento personalizadas
- [ ] Planes financieros multi-año basados en objetivos

---

## 📚 Archivos de Referencia

```
Modelos:
- lib/features/auth/models/user_profile_model.dart
- lib/features/auth/models/edit_profile_model.dart

ViewModels:
- lib/features/auth/viewmodels/edit_profile_viewmodel.dart

Vistas:
- lib/features/auth/views/edit_profile_page.dart

Servicios:
- lib/features/analysis/services/financial_analysis_service.dart

Documentación:
- ENRIQUECIMIENTO_PERFIL_IA.md (este archivo)
- ANALISIS_FINANCIERO_COMPLETO.md
- ANALISIS_FINANCIERO_GUIA_RAPIDA.md
```

---

## 🔍 Verificación Final

```bash
# Compilar sin errores
flutter pub get
flutter analyze

# Ejecutar app
flutter run

# Probar flujo completo:
1. Ir a Perfil → Editar
2. Llenar sección "Información Demográfica"
3. Guardar
4. Ir a tab Análisis
5. Ejecutar "Analizar Finanzas"
6. Verificar que recomendaciones son personalizadas
```

**Estado:** ✅ **COMPLETO Y FUNCIONAL**

---

**Desarrollado con ❤️ para VanguardMoney**
*Análisis financiero inteligente y personalizado powered by Gemini 2.0*
