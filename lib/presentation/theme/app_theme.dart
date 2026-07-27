import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color whatsappTeal = Color(0xFF075E54);
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color telegramBlue = Color(0xFF0088CC);
  static const Color chatBgLight = Color(0xFFC8BBA8);
  static const Color outgoingLight = Color(0xFFB8E896);
  static const Color incomingLight = Colors.white;

  // Light mode non-gray tones (teal-based)
  static const Color lightTextPrimary = Color(0xFF1A3B2E);
  static const Color lightTextSecondary = Color(0xFF1A3B2E);
  static const Color lightTextTertiary = Color(0xFF3D6B55);
  static const Color lightIconColor = Color(0xFF3D6B55);
  static const Color lightSurfaceVariant = Color(0xFFD8CFC0);
  static const Color lightDividerColor = Color(0xFFC5BAAA);

  static const Color whatsappDarkTeal = Color(0xFF00A884);
  static const Color telegramLightBlue = Color(0xFF4FC3F7);
  static const Color chatBgDark = Color(0xFF0B141A);
  static const Color outgoingDark = Color(0xFF005C4B);
  static const Color incomingDark = Color(0xFF1F2C33);
  static const Color surfaceDark = Color(0xFF111B21);

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: whatsappTeal,
      secondary: telegramBlue,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: chatBgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: whatsappTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: lightTextTertiary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: whatsappTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: whatsappTeal,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: whatsappDarkTeal,
      secondary: telegramLightBlue,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: chatBgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: incomingDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: incomingDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: whatsappDarkTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: whatsappDarkTeal,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static PageRouteBuilder smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
