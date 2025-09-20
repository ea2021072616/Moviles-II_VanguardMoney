/// Constantes específicas para el módulo de autenticación
class AuthConstants {
  // UI Sizing
  static const double maxCardWidth = 400.0;
  static const double logoSize = 85.0;
  static const double buttonHeight = 58.0;
  static const double cardElevation = 25.0;

  // Typography
  static const double titleFontSize = 32.0;
  static const double titleLetterSpacing = -1.2;
  static const double subtitleFontSize = 16.0;
  static const double strengthIndicatorFontSize = 12.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Padding multipliers for responsiveness
  static const double mobilePaddingFactor = 0.05;
  static const double tabletPaddingFactor = 0.08;
  static const double desktopPaddingFactor = 0.12;

  // Animation durations
  static const Duration formTransitionDuration = Duration(milliseconds: 300);
  static const Duration strengthIndicatorDuration = Duration(milliseconds: 200);

  // Currency options
  static const List<Map<String, String>> currencies = [
    {'code': 'S/', 'name': 'Sol Peruano (S/)'},
    {'code': 'USD', 'name': 'Dólar Americano (USD)'},
    {'code': 'EUR', 'name': 'Euro (EUR)'},
    {'code': 'GBP', 'name': 'Libra Esterlina (GBP)'},
  ];

  // Password strength levels
  static const List<String> strengthLabels = [
    'Muy Débil',
    'Débil',
    'Regular',
    'Buena',
    'Fuerte',
    'Muy Fuerte',
  ];
}

/// Helper para obtener padding responsivo
class AuthResponsive {
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth < AuthConstants.mobileBreakpoint) {
      return screenWidth * AuthConstants.mobilePaddingFactor;
    } else if (screenWidth < AuthConstants.tabletBreakpoint) {
      return screenWidth * AuthConstants.tabletPaddingFactor;
    } else {
      return screenWidth * AuthConstants.desktopPaddingFactor;
    }
  }

  static double getCardWidth(double screenWidth) {
    final maxWidth = AuthConstants.maxCardWidth;
    final responsiveWidth = screenWidth * 0.9;
    return responsiveWidth < maxWidth ? responsiveWidth : maxWidth;
  }

  static bool isMobile(double screenWidth) =>
      screenWidth < AuthConstants.mobileBreakpoint;

  static bool isTablet(double screenWidth) =>
      screenWidth >= AuthConstants.mobileBreakpoint &&
      screenWidth < AuthConstants.tabletBreakpoint;
}
