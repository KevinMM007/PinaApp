import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Paleta de colores modernos inspirados en la piña 🍍

  // Verdes principales (más vibrantes y variados)
  static const Color primaryGreen = Color(0xFF2E7D32); // Verde oscuro elegante
  static const Color primaryGreenLight = Color(0xFF4CAF50); // Verde medio
  static const Color accentGreen = Color(0xFF66BB6A); // Verde claro
  static const Color darkGreen = Color(0xFF1B5E20); // Verde muy oscuro

  // Dorados y amarillos (más ricos)
  static const Color primaryGold = Color(0xFFFFB300); // Dorado principal
  static const Color lightGold = Color(0xFFFFD54F); // Dorado claro
  static const Color darkGold = Color(0xFFFF8F00); // Dorado oscuro

  // Acentos cálidos
  static const Color accentOrange = Color(0xFFFF7043); // Naranja cálido
  static const Color accentRed = Color(0xFFE53935); // Rojo acento

  // Neutros modernos
  static const Color surfaceWhite = Color(0xFFFAFAFA); // Blanco superficie
  static const Color backgroundLight = Color(0xFFF5F5F5); // Fondo claro
  static const Color cardWhite = Color(0xFFFFFFFF); // Blanco tarjetas
  static const Color textPrimary = Color(0xFF212121); // Texto principal
  static const Color textSecondary = Color(0xFF757575); // Texto secundario
  static const Color textHint = Color(0xFFBDBDBD); // Texto hint
  static const Color divider = Color(0xFFE0E0E0); // Divisores

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, accentGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, lightGold],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, primaryGold],
  );

  // Sistema de espaciado
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Radios de borde
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Elevaciones
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Colores principales
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: accentGreen,
      onPrimaryContainer: darkGreen,
      secondary: primaryGold,
      onSecondary: Colors.white,
      secondaryContainer: lightGold,
      onSecondaryContainer: darkGold,
      tertiary: accentOrange,
      onTertiary: Colors.white,
      surface: surfaceWhite,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
    ),

    // Configuración del Scaffold
    scaffoldBackgroundColor: backgroundLight,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: elevationLow,
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      color: cardWhite,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(
        horizontal: space8,
        vertical: space4,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: elevationMedium,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: textHint,
        disabledForegroundColor: Colors.white,
        shadowColor: primaryGreen.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          vertical: space16,
          horizontal: space24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        side: const BorderSide(color: primaryGreen, width: 2),
        padding: const EdgeInsets.symmetric(
          vertical: space16,
          horizontal: space24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(
          vertical: space12,
          horizontal: space20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGold,
      foregroundColor: Colors.white,
      elevation: elevationHigh,
      shape: CircleBorder(),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: space16,
        vertical: space16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: divider, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: textHint,
        fontSize: 16,
      ),
      errorStyle: const TextStyle(
        color: error,
        fontSize: 14,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardWhite,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: elevationHigh,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: backgroundLight,
      selectedColor: primaryGreen,
      disabledColor: textHint,
      labelStyle: const TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: space12,
        vertical: space8,
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
      linearTrackColor: divider,
      circularTrackColor: divider,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),

    // Text Theme
    textTheme: const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.3,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.4,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.3,
        height: 1.5,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.3,
        height: 1.5,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.3,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.4,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
        height: 1.4,
      ),
    ),
  );

  // Métodos helper para crear sombras personalizadas
  static List<BoxShadow> createShadow({
    double elevation = elevationMedium,
    Color? color,
    double opacity = 0.1,
  }) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withOpacity(opacity),
        offset: Offset(0, elevation / 2),
        blurRadius: elevation,
        spreadRadius: 0,
      ),
    ];
  }

  // Crear gradientes personalizados
  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [startColor, endColor],
    );
  }

  // Métodos para obtener colores con opacidad
  static Color primaryWithOpacity(double opacity) =>
      primaryGreen.withOpacity(opacity);

  static Color secondaryWithOpacity(double opacity) =>
      primaryGold.withOpacity(opacity);
}
