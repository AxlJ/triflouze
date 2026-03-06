import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TriflouzeTheme {
  TriflouzeTheme._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6B9E7A);
  static const Color primaryDark = Color(0xFF2D5A3D);
  static const Color secondary = Color(0xFFC97A5A);
  static const Color surface = Color(0xFFFBF7F0);
  static const Color accent = Color(0xFFE8B86D);
  static const Color textDark = Color(0xFF3D2B1F);
  static const Color textMedium = Color(0xFF7A6555);
  static const Color border = Color(0xFFD6C9BE);

  // ── Chart palette (warm & cohesive) ───────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF6B9E7A),
    Color(0xFFC97A5A),
    Color(0xFFE8B86D),
    Color(0xFF9B8EA0),
    Color(0xFF5B9EC9),
    Color(0xFFD4A373),
    Color(0xFF8DB5A0),
    Color(0xFFE07A5F),
    Color(0xFFF2CC8F),
    Color(0xFF81B29A),
  ];

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          secondary: secondary,
          surface: surface,
          onSurface: textDark,
          outline: border,
        ),
        scaffoldBackgroundColor: surface,
        textTheme: _buildTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textDark,
            side: const BorderSide(color: border),
            textStyle:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle:
                GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          labelStyle: GoogleFonts.nunito(
              color: textMedium, fontWeight: FontWeight.w500),
          hintStyle: GoogleFonts.nunito(color: textMedium),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: primary,
          side: const BorderSide(color: border),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w600, fontSize: 13, color: textDark),
          secondaryLabelStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
          showCheckmark: false,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE8DDD5)),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryDark,
          contentTextStyle: GoogleFonts.nunito(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: primary),
        dialogTheme: DialogThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          titleTextStyle: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark),
          contentTextStyle: GoogleFonts.nunito(
              fontSize: 14, color: textMedium),
        ),
      );

  static TextTheme _buildTextTheme() => GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
            fontWeight: FontWeight.w800, color: textDark),
        displayMedium: GoogleFonts.nunito(
            fontWeight: FontWeight.w700, color: textDark),
        headlineLarge: GoogleFonts.nunito(
            fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.nunito(
            fontWeight: FontWeight.w700, color: textDark),
        titleLarge: GoogleFonts.nunito(
            fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.nunito(
            fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.nunito(
            fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.nunito(
            fontWeight: FontWeight.w400, color: textDark),
        labelLarge: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.nunito(fontWeight: FontWeight.w500),
      );
}
