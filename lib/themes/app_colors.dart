import 'package:flutter/material.dart';


class AppColors {
  static final Color _defaultPrimary = const Color(0xFFFFFFFF); // Pure white for a crisp, clean background
  static final Color _defaultSecondary = const Color(0xFFFFFFFF); // Very light gray for subtle contrast
  static final Color _defaultTheme = const Color(0xFFD9A556); // A vibrant blue that stands out for headers and buttons
  static final Color _defaultTextPrimary = const Color(0xFF212529); // Strong dark gray, perfect for primary text
  static final Color _defaultTextSecondary = const Color.fromARGB(255, 38, 38, 39); // Muted gray for secondary text or captions

  static final Color _defaultPrimaryDark = const Color(0xFF121212);
  static final Color _defaultSecondaryDark = const Color(0xFF1E1E1E);
  static final Color _defaultThemeDark = const Color(0xFFFFD700);
  static final Color _defaultTextPrimaryDark = const Color(0xFFFFFFFF);
  static final Color _defaultTextSecondaryDark = const Color(0xFFB0B0B0);

  static Color primary = _defaultPrimaryDark;
  static Color secondary = _defaultSecondaryDark;
  static Color theme = _defaultThemeDark;
  static Color textPrimary = _defaultTextPrimaryDark;
  static Color textSecondary = _defaultTextSecondaryDark;

  static void resetToDefault() {
    primary = _defaultPrimary;
    secondary = _defaultSecondary;
    theme = _defaultTheme;
    textPrimary = _defaultTextPrimary;
    textSecondary = _defaultTextSecondary;
  }

  static void resetToDarkMode() {
    primary = _defaultPrimaryDark;
    secondary = _defaultSecondaryDark;
    theme = _defaultThemeDark;
    textPrimary = _defaultTextPrimaryDark;
    textSecondary = _defaultTextSecondaryDark;
  }
} 
