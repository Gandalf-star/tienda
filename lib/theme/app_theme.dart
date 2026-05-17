import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Color Palette ─────────────────────────────────
  static const Color bgPrimary = Color(0xFF0B0B0F);
  static const Color bgSecondary = Color(0xFF101018);
  static const Color surface = Color(0xFF1A1A26);
  static const Color surfaceLight = Color(0xFF222233);
  static const Color surfaceBorder = Color(0xFF2C2C40);

  static const Color gold = Color(0xFFCDA76A);
  static const Color goldLight = Color(0xFFE2CFA6);
  static const Color goldDark = Color(0xFFAA8844);

  static const Color textPrimary = Color(0xFFF5F0EB);
  static const Color textSecondary = Color(0xFF9898AC);
  static const Color textMuted = Color(0xFF5C5C72);

  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF87171);
  static const Color whatsapp = Color(0xFF25D366);

  // ─── Gradients ─────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xBB000000)],
    stops: [0.35, 1.0],
  );

  // ─── Decorations ───────────────────────────────────
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceBorder.withValues(alpha: 0.5)),
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceBorder.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ─── Theme Data ────────────────────────────────────
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: surface,
        error: error,
        onPrimary: bgPrimary,
        onSecondary: bgPrimary,
        onSurface: textPrimary,
      ),
      useMaterial3: true,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceBorder.withValues(alpha: 0.5)),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: textMuted),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bgPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(color: textSecondary),
        hintStyle: GoogleFonts.poppins(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: gold.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: textPrimary),
        side: BorderSide(color: surfaceBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: GoogleFonts.poppins(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: bgPrimary,
        elevation: 4,
      ),

      dividerTheme: DividerThemeData(
        color: surfaceBorder.withValues(alpha: 0.5),
        thickness: 1,
      ),

      iconTheme: const IconThemeData(color: textSecondary),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold.withValues(alpha: 0.3);
          }
          return surfaceBorder;
        }),
      ),
    );
  }
}
