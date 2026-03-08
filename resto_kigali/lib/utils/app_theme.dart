import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryDark = Color(0xFF0A1428);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Light content colors
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardGrey = Color(0xFFF3F4F6);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);

  /// Dark theme configuration matching resto_kigali aesthetic
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accentGold,
      scaffoldBackgroundColor: primaryDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textSecondary,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(color: textSecondary),
        hintStyle: GoogleFonts.roboto(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.roboto(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Returns a category-specific icon.
  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.coffee;
      case 'Fast Food':
        return Icons.fastfood;
      case 'Bakery':
        return Icons.bakery_dining;
      case 'Bar':
        return Icons.local_bar;
      case 'Buffet':
        return Icons.lunch_dining;
      case 'Diner':
        return Icons.dining;
      case 'Picnic Area':
        return Icons.park;
      case 'Food Stall':
        return Icons.storefront;
      case 'Hotel':
        return Icons.hotel;
      default:
        return Icons.restaurant;
    }
  }

  /// Returns a category-specific gradient for placeholder backgrounds.
  static List<Color> categoryGradient(String category) {
    switch (category) {
      case 'Restaurant':
        return const [Color(0xFFFF6B35), Color(0xFFFF8E53)];
      case 'Café':
        return const [Color(0xFF6F4E37), Color(0xFF8B6F47)];
      case 'Fast Food':
        return const [Color(0xFFE53935), Color(0xFFFF6659)];
      case 'Bakery':
        return const [Color(0xFFD4A574), Color(0xFFE8C9A0)];
      case 'Bar':
        return const [Color(0xFF7B1FA2), Color(0xFF9C4DCC)];
      case 'Buffet':
        return const [Color(0xFF2E7D32), Color(0xFF4CAF50)];
      case 'Diner':
        return const [Color(0xFFE65100), Color(0xFFFF8A50)];
      case 'Picnic Area':
        return const [Color(0xFF33691E), Color(0xFF689F38)];
      case 'Food Stall':
        return const [Color(0xFFF9A825), Color(0xFFFFD54F)];
      case 'Hotel':
        return const [Color(0xFF1565C0), Color(0xFF42A5F5)];
      default:
        return const [Color(0xFF455A64), Color(0xFF78909C)];
    }
  }

  /// Builds a placeholder widget with category-specific icon and gradient.
  static Widget categoryPlaceholder(String category, {double height = 180}) {
    final colors = categoryGradient(category);
    final icon = categoryIcon(category);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
