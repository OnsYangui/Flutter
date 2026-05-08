import 'package:flutter/material.dart';

/// Extension sur BuildContext pour des couleurs adaptatives clair/sombre
extension OzTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get bgColor =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FAFB);
  Color get bgSecondary =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get cardBg => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get headerBg => isDark ? const Color(0xFF1E293B) : Colors.white;

  // Gradient du header (teal vers fond)
  List<Color> get headerGradient => isDark
      ? [const Color(0xFF006978), const Color(0xFF0F172A)]
      : [const Color(0xFF00BCD4), const Color(0xFFF0FAFB)];

  // Textes
  Color get textPrimary =>
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1A1A2E);
  Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF9E9BB4);
  Color get textHint =>
      isDark ? const Color(0xFF64748B) : const Color(0xFFB0AEC8);

  // Bordures / Dividers
  Color get borderColor =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE8E6F5);
  Color get dividerColor =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF0EFF8);

  // Champs de saisie
  Color get inputBg =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FAFB);
  Color get inputBorder =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  // Ombre des cartes
  Color get shadowColor => isDark
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.05);

  // Couleur primaire (reste la même)
  static const Color primary = Color(0xFF00BCD4);
}
