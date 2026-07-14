import 'package:flutter/material.dart';

/// Centralized light/dark theme definitions for PwBox.
///
/// Provides Material 3 themes built from a blue/teal security-oriented seed
/// color. Both themes use [ColorScheme.fromSeed] so all derived colors
/// (surfaces, outlines, elevations, etc.) stay consistent.
class AppTheme {
  AppTheme._();

  static const Color _lightSeed = Color(0xFF1565C0);
  static const Color _darkSeed = Color(0xFF90CAF9);

  static final ThemeData lightTheme = _buildLightTheme();
  static final ThemeData darkTheme = _buildDarkTheme();

  // ---------------------------------------------------------------------------
  // Light
  // ---------------------------------------------------------------------------
  static ThemeData _buildLightTheme() {
    final ColorScheme lightScheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,

      // ---- AppBar ----------------------------------------------------------
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: lightScheme.surface,
        foregroundColor: lightScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: lightScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightScheme.onSurfaceVariant),
      ),

      // ---- Card ------------------------------------------------------------
      cardTheme: CardThemeData(
        elevation: 1,
        color: lightScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ---- Buttons ---------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ---- Input fields ----------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightScheme.error, width: 2),
        ),
      ),

      // ---- Dropdown --------------------------------------------------------
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightScheme.outlineVariant),
          ),
        ),
      ),

      // ---- Dialog ----------------------------------------------------------
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ---- Divider ---------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: lightScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ---- ListTile --------------------------------------------------------
      listTileTheme: ListTileThemeData(
        iconColor: lightScheme.onSurfaceVariant,
        textColor: lightScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ---- Switch ----------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.primary;
          }
          return lightScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightScheme.primaryContainer;
          }
          return lightScheme.surfaceContainerHighest;
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark
  // ---------------------------------------------------------------------------
  static ThemeData _buildDarkTheme() {
    final ColorScheme darkScheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,

      // ---- AppBar ----------------------------------------------------------
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: darkScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkScheme.onSurfaceVariant),
      ),

      // ---- Card ------------------------------------------------------------
      cardTheme: CardThemeData(
        elevation: 1,
        color: darkScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ---- Buttons ---------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ---- Input fields ----------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkScheme.error, width: 2),
        ),
      ),

      // ---- Dropdown --------------------------------------------------------
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkScheme.surfaceContainerLowest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkScheme.outlineVariant),
          ),
        ),
      ),

      // ---- Dialog ----------------------------------------------------------
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ---- Divider ---------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: darkScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ---- ListTile --------------------------------------------------------
      listTileTheme: ListTileThemeData(
        iconColor: darkScheme.onSurfaceVariant,
        textColor: darkScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ---- Switch ----------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primary;
          }
          return darkScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScheme.primaryContainer;
          }
          return darkScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}
