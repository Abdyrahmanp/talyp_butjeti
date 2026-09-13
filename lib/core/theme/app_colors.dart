import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkCard = Color(0xFF1E293B);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color lightCard = Color(0xFFFFFFFF);

  // Vibrant Accents
  static const Color primary = Color(0xFF6366F1);      // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5);  // Indigo 600

  static const Color secondary = Color(0xFF0EA5E9);    // Sky 500
  static const Color accentTeal = Color(0xFF14B8A6);   // Teal 500
  static const Color emerald = Color(0xFF10B981);      // Emerald 500 (Income / Under budget)
  static const Color amber = Color(0xFFF59E0B);        // Amber 500 (Warnings / impulse)
  static const Color rose = Color(0xFFF43F5E);         // Rose 500 (Expenses / Debts)
  static const Color purple = Color(0xFF8B5CF6);       // Purple 500 (Subscriptions)

  // Neutral Grays
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Glassmorphism overlays
  static Color glassWhite = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.12);
}
