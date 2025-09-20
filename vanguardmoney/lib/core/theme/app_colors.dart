import 'package:flutter/material.dart';

/// Colores oficiales del branding VanguardMoney
class AppColors {
  // ========== COLORES BASE ==========
  /// Blanco principal - fondo principal de la app
  static const Color white = Color(0xFFFFFFFF);

  /// Negro gris - texto principal y elementos de contraste
  static const Color blackGrey = Color(0xFF242424);

  // ========== BRAND COLOURS (Acentos, categorías, tarjetas) ==========

  /// Rojo coral - Gastos, alertas, botones críticos
  static const Color redCoral = Color(0xFFE0533D);

  /// Azul lavanda - Categorías, fondos suaves
  static const Color blueLavender = Color(0xFF9DA7D0);

  /// Verde jade - Ahorros, ingresos, validaciones
  static const Color greenJade = Color(0xFF469B88);

  /// Azul clásico - Categorías, fondos, botones info (COLOR PRINCIPAL)
  static const Color blueClassic = Color(0xFF377CC8);

  /// Amarillo pastel - Advertencias, metas, resaltes
  static const Color yellowPastel = Color(0xFFEED868);

  /// Rosa pastel - Categorías, fondos
  static const Color pinkPastel = Color(0xFFE78C9D);

  // ========== COLORES DERIVADOS ==========

  /// Variaciones del color principal (Azul clásico)
  static const Color primaryLight = Color(0xFF5B94D1);
  static const Color primaryDark = Color(0xFF2A5F9E);

  /// Grises neutros para UI
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF757575);

  /// Colores de estado
  static const Color success = greenJade;
  static const Color warning = yellowPastel;
  static const Color error = redCoral;
  static const Color info = blueClassic;

  // ========== GRADIENTES PARA ELEMENTOS ESPECIALES ==========

  /// Gradiente principal para botón de IA y elementos destacados
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [blueClassic, blueLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para elementos de ahorro/ingresos
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [greenJade, Color(0xFF5BB29F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para elementos de gastos/alertas
  static const LinearGradient expenseGradient = LinearGradient(
    colors: [redCoral, Color(0xFFE7704F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente suave para fondos de tarjetas
  static const LinearGradient cardGradient = LinearGradient(
    colors: [white, Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== PALETA DE CATEGORÍAS ==========
  /// Lista de colores para diferenciar categorías de transacciones
  static const List<Color> categoryColors = [
    blueClassic, // Azul clásico
    greenJade, // Verde jade
    redCoral, // Rojo coral
    pinkPastel, // Rosa pastel
    yellowPastel, // Amarillo pastel
    blueLavender, // Azul lavanda
  ];

  // ========== MÉTODOS ÚTILES ==========

  /// Obtiene un color de categoría basado en un índice
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// Obtiene una versión con opacidad de cualquier color
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Obtiene el color de texto apropiado para un fondo dado
  static Color getTextColor(Color backgroundColor) {
    // Calcula la luminancia para determinar si usar texto claro u oscuro
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? blackGrey : white;
  }
}
