import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Sistema de tema completo para VanguardMoney
/// Implementa el design system usando los colores oficiales del branding
class AppTheme {
  // ========== TEMA CLARO (Principal) ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme usando el branding VanguardMoney
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blueClassic,
        brightness: Brightness.light,
        primary: AppColors.blueClassic,
        onPrimary: AppColors.white,
        secondary: AppColors.greenJade,
        onSecondary: AppColors.white,
        error: AppColors.redCoral,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.blackGrey,
        background: AppColors.white,
        onBackground: AppColors.blackGrey,
        outline: AppColors.greyMedium,
        outlineVariant: AppColors.greyLight,
      ),

      // ========== SCAFFOLD ==========
      scaffoldBackgroundColor: AppColors.white,

      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackGrey,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          color: AppColors.blackGrey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.blackGrey, size: 24),
        actionsIconTheme: const IconThemeData(
          color: AppColors.blackGrey,
          size: 24,
        ),
      ),

      // ========== NAVEGACIÓN ==========
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.blueClassic,
        unselectedItemColor: AppColors.greyDark,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
        ),
      ),

      // ========== BOTONES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueClassic,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.greyLight,
          disabledForegroundColor: AppColors.greyDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppColors.withOpacity(AppColors.blueClassic, 0.3),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueClassic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blueClassic,
          side: const BorderSide(color: AppColors.blueClassic, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blueClassic,
        foregroundColor: AppColors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // ========== TARJETAS ==========
      cardTheme: CardThemeData(
        color: AppColors.white,
        shadowColor: AppColors.withOpacity(AppColors.blackGrey, 0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),

      // ========== CAMPOS DE TEXTO ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.greyLight,
        hintStyle: TextStyle(
          color: AppColors.withOpacity(AppColors.blackGrey, 0.6),
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.blackGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        // Estados de los bordes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyMedium, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blueClassic, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redCoral, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redCoral, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.greyLight, width: 1),
        ),

        // Padding interno
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        // Colores de error
        errorStyle: const TextStyle(color: AppColors.redCoral, fontSize: 12),
      ),

      // ========== TIPOGRAFÍA ==========
      textTheme: const TextTheme(
        // Títulos grandes
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.blackGrey,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.blackGrey,
          letterSpacing: -0.8,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
          letterSpacing: -0.5,
        ),

        // Títulos de sección
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
        ),

        // Títulos de tarjetas y componentes
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.blackGrey,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.blackGrey,
        ),

        // Texto del cuerpo
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.blackGrey,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.blackGrey,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.greyDark,
          height: 1.3,
        ),

        // Etiquetas y botones
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.blackGrey,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.blackGrey,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.greyDark,
          letterSpacing: 0.2,
        ),
      ),

      // ========== DIVIDERS ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.greyLight,
        thickness: 1,
        space: 1,
      ),

      // ========== CHIPS ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greyLight,
        selectedColor: AppColors.blueClassic,
        disabledColor: AppColors.greyLight,
        labelStyle: const TextStyle(color: AppColors.blackGrey, fontSize: 12),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.greyMedium),
      ),

      // ========== ICONOS ==========
      iconTheme: const IconThemeData(color: AppColors.blackGrey, size: 24),

      // ========== LISTAS ==========
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  // ========== TEMA OSCURO (Futuro) ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blueClassic,
        brightness: Brightness.dark,
        primary: AppColors.blueClassic,
        onPrimary: AppColors.white,
        secondary: AppColors.greenJade,
        surface: AppColors.blackGrey,
        onSurface: AppColors.white,
        background: const Color(0xFF121212),
        onBackground: AppColors.white,
        error: AppColors.redCoral,
      ),
      // TODO: Implementar theme completo cuando se requiera modo oscuro
    );
  }
}

/// Extensiones útiles para trabajar con el tema
extension ThemeExtensions on ThemeData {
  /// Obtiene el gradiente principal para elementos destacados
  Gradient get primaryGradient => AppColors.primaryGradient;

  /// Obtiene el gradiente para elementos de ingreso
  Gradient get incomeGradient => AppColors.incomeGradient;

  /// Obtiene el gradiente para elementos de gasto
  Gradient get expenseGradient => AppColors.expenseGradient;

  /// Obtiene un color de categoría basado en un índice
  Color getCategoryColor(int index) => AppColors.getCategoryColor(index);
}
