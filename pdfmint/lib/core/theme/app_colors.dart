import 'package:flutter/material.dart';

class AppColors {
  // Ana Renk - Tiffany Blue
  static const Color primary = Color(0xFF81D8D0);
  static const Color primaryLight = Color(0xFFB3EAE6);
  static const Color primaryDark = Color(0xFF4FBFB5);
  static const Color primaryDeep = Color(0xFF2A9D94);

  // Yardımcı Renkler
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F7FA);
  static const Color mediumGrey = Color(0xFFE2E8F0);
  static const Color darkGrey = Color(0xFF64748B);
  static const Color charcoal = Color(0xFF1E293B);

  // Durum Renkleri
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Araç Kategorisi Renkleri
  static const Color toolOrganize = Color(0xFF81D8D0);    // Tiffany
  static const Color toolConvert = Color(0xFF7C3AED);     // Mor
  static const Color toolEdit = Color(0xFFF59E0B);        // Sarı
  static const Color toolSecurity = Color(0xFFEF4444);    // Kırmızı
  static const Color toolOcr = Color(0xFF22C55E);         // Yeşil
  static const Color toolOptimize = Color(0xFF3B82F6);    // Mavi

  // Aydınlık Tema
  static const Color lightBackground = Color(0xFFF8FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Karanlık Tema
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF81D8D0), Color(0xFF4FBFB5)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB3EAE6), Color(0xFF81D8D0)],
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );
}
