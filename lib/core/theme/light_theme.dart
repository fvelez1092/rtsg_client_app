import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorsApp {
  // Brand colors (from logo)
  static const primary = Color(0xFF538241); // ✅ Green (MAIN)
  static const secondary = Color(0xFFAA1D22); // Red (brand / warning)
  static const accent = Color(0xFFE3C543); // Yellow (CTA / highlight)

  // Neutrals
  static const black = Color(0xFF272624);
  static const white = Color(0xFFFCFBF8);
  static const gray = Color(0xFFAFA5A1);

  // Light mode
  static const lightBackground = Color(0xFFF6F7F5);
  static const lightSurface = Color(0xFFFFFFFF);

  // Dark mode
  static const darkBackground = Color(0xFF0F1110);
  static const darkSurface = Color(0xFF1A1C1B);

  // Text
  static const textOnLight = black;
  static const textOnDark = white;
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  textTheme: GoogleFonts.robotoTextTheme(),
  fontFamily: GoogleFonts.roboto().fontFamily,
  scaffoldBackgroundColor: ColorsApp.lightBackground,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,

    primary: ColorsApp.primary,
    onPrimary: ColorsApp.white,

    secondary: ColorsApp.secondary,
    onSecondary: ColorsApp.white,

    tertiary: ColorsApp.accent,
    onTertiary: ColorsApp.black,

    surface: ColorsApp.lightSurface,
    onSurface: ColorsApp.textOnLight,

    error: ColorsApp.secondary,
    onError: ColorsApp.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: ColorsApp.primary,
    foregroundColor: ColorsApp.white,
    centerTitle: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorsApp.primary,
      foregroundColor: ColorsApp.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorsApp.accent,
    foregroundColor: ColorsApp.black,
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorsApp.primary),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorsApp.lightSurface,
    hintStyle: const TextStyle(color: ColorsApp.gray),
    labelStyle: const TextStyle(color: ColorsApp.primary),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorsApp.gray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorsApp.primary, width: 2),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.robotoTextTheme(),
  fontFamily: GoogleFonts.roboto().fontFamily,
  scaffoldBackgroundColor: ColorsApp.darkBackground,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,

    primary: ColorsApp.primary,
    onPrimary: ColorsApp.white,

    secondary: ColorsApp.secondary,
    onSecondary: ColorsApp.white,

    tertiary: ColorsApp.accent,
    onTertiary: ColorsApp.black,

    surface: ColorsApp.darkSurface,
    onSurface: ColorsApp.textOnDark,

    error: ColorsApp.secondary,
    onError: ColorsApp.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: ColorsApp.darkSurface,
    foregroundColor: ColorsApp.white,
    centerTitle: true,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorsApp.primary,
      foregroundColor: ColorsApp.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorsApp.accent,
    foregroundColor: ColorsApp.black,
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: ColorsApp.accent),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorsApp.darkSurface,
    hintStyle: const TextStyle(color: ColorsApp.gray),
    labelStyle: const TextStyle(color: ColorsApp.primary),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorsApp.gray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorsApp.primary, width: 2),
    ),
  ),
);
