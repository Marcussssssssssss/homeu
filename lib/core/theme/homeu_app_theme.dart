import 'package:flutter/material.dart';

class HomeUAppTheme {
  HomeUAppTheme._();

  static const Color brandPrimary = Color(0xFF1E3A8A);
  static const Color brandSecondary = Color(0xFF10B981);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: brandPrimary,
      secondary: brandSecondary,
      brightness: Brightness.light,
      surface: const Color(0xFFF6F8FC),
    );

    return _baseTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: const Color(0xFF9AB4FF),
      secondary: const Color(0xFF64E4B7),
      brightness: Brightness.dark,
      surface: const Color(0xFF0B111D),
    );

    return _baseTheme(colorScheme);
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF172336) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF111A2A) : Colors.white,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111A2B) : Colors.white,
        indicatorColor: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFFEAF0FF) : colorScheme.primary)
                : (isDark ? const Color(0xFFB0BED5) : colorScheme.onSurfaceVariant),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? (isDark ? const Color(0xFFEAF0FF) : colorScheme.primary)
                : (isDark ? const Color(0xFFB0BED5) : colorScheme.onSurfaceVariant),
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF141C2B) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF141C2B) : Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1B2433) : const Color(0xFF1F314F),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      textTheme: ThemeData(brightness: colorScheme.brightness).textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}

extension HomeUThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get homeuCard => isDarkMode ? const Color(0xFF172336) : Colors.white;
  Color get homeuRaisedCard => isDarkMode ? const Color(0xFF1E2D44) : const Color(0xFFF8FAFF);
  Color get homeuPrimaryText => isDarkMode ? const Color(0xFFEAF0FF) : colors.onSurface;
  Color get homeuSecondaryText =>
      isDarkMode ? const Color(0xFFBDC9DE) : colors.onSurface.withValues(alpha: 0.82);
  Color get homeuMutedText =>
      isDarkMode ? const Color(0xFFA3B0C6) : colors.onSurfaceVariant.withValues(alpha: 0.95);
  Color get homeuHelperText =>
      isDarkMode ? const Color(0xFF95A4BD) : colors.onSurfaceVariant.withValues(alpha: 0.88);
  Color get homeuAccent => colors.primary;
  Color get homeuPrice => HomeUAppTheme.brandSecondary;
  Color get homeuSoftBorder => isDarkMode
      ? const Color(0xFF334766)
      : colors.outline.withValues(alpha: 0.35);
  Color get homeuStrongBorder => isDarkMode
      ? const Color(0xFF486389)
      : colors.outline.withValues(alpha: 0.5);
  Color get homeuSectionDivider => isDarkMode
      ? const Color(0xFF2D3F5B)
      : colors.outline.withValues(alpha: 0.25);
  Color get homeuCardShadow => isDarkMode
      ? Colors.black.withValues(alpha: 0.22)
      : colors.primary.withValues(alpha: 0.14);
  Color get homeuSuccess => colors.secondary;
}

