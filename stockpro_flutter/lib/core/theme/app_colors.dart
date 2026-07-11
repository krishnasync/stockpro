import 'package:flutter/material.dart';

/// Brand palette. Kept separate from app_theme.dart so designers/PMs can
/// review just the colors without wading through ThemeData boilerplate.
class AppColors {
  AppColors._();

  // Primary — deep indigo, reads as "enterprise" rather than "consumer app"
  static const Color primary = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF1E1B4B);

  // Semantic
  static const Color success = Color(0xFF16A34A); // in stock / paid / approved
  static const Color warning = Color(0xFFD97706);  // low stock / pending
  static const Color danger = Color(0xFFDC2626);   // out of stock / overdue
  static const Color info = Color(0xFF0284C7);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF161E2E);
  static const Color darkBorder = Color(0xFF283449);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
