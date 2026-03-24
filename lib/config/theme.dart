import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors (from Style Guide)
  static const Color primaryNavy = Color(0xFF14213D);  // Prussian Blue
  static const Color primaryBlue = Color(0xFF14213D);  // Alias for backward compatibility
  static const Color primaryBlack = Color(0xFF000000);
  static const Color accentOrange = Color(0xFFFCA311);
  static const Color backgroundGray = Color(0xFFE5E5E5);  // Alabaster Grey
  static const Color cardColor = Color(0xFFFFFFFF);

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFCA311);
  static const Color infoBlue = Color(0xFF14213D);

  // Text Colors
  static const Color textPrimary = Color(0xFF14213D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Spacing System (8px base)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Padding
  static const double paddingScreen = 20.0;
  static const double paddingCard = 18.0;
  static const double paddingInput = 12.0;

  // Border Radius
  static const double radiusButton = 12.0;
  static const double radiusCard = 18.0;
  static const double radiusInput = 12.0;
  static const double radiusModal = 20.0;

  // Typography (from Style Guide)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Roboto',
    height: 1.6,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Roboto',
  );

  // Primary Gradient (from Style Guide)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlack, primaryNavy],
  );

  // Soft Shadow (from Style Guide)
  static const BoxShadow softShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.12),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryNavy,
      scaffoldBackgroundColor: backgroundGray,
      fontFamily: 'Roboto',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: textOnDark,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textOnDark,
          fontFamily: 'Roboto',
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: primaryBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: primaryNavy, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: textHint),
        ),
        contentPadding: const EdgeInsets.all(paddingInput),
        labelStyle: labelMedium,
        hintStyle: const TextStyle(
          color: textHint,
          fontFamily: 'Roboto',
        ),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 12,
          fontFamily: 'Roboto',
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        margin: const EdgeInsets.symmetric(vertical: spacingS),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusModal),
        ),
        titleTextStyle: titleLarge,
        contentTextStyle: bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryNavy,
        contentTextStyle: const TextStyle(
          color: textOnDark,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusInput),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelMedium: labelMedium,
      ),
    );
  }
}
