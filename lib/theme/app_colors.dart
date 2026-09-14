import 'package:flutter/material.dart';

/// Palette de couleurs de l'application Ziko.
/// Reprend exactement les couleurs utilisées dans la maquette HTML/CSS
/// du Livrable 0, pour garder une cohérence visuelle.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F5F9);
  static const Color ink = Color(0xFF1D2233);
  static const Color inkSoft = Color(0xFF5B6072);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE4E6EE);

  static const Color accent = Color(0xFF4B4E9E);
  static const Color accentSoft = Color(0xFFEDEDFA);

  // Couleurs de priorité (identiques à la maquette)
  static const Color high = Color(0xFFE2574C);
  static const Color highBg = Color(0xFFFCEAE8);

  static const Color mid = Color(0xFFE8A33D);
  static const Color midBg = Color(0xFFFDF3E3);

  static const Color low = Color(0xFF4C9F70);
  static const Color lowBg = Color(0xFFE9F5EE);
}