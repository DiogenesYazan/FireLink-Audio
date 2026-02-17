import 'package:flutter/material.dart';

/// Paleta de cores do FireLink Audio.
///
/// Gradientes entre Lilás (#C77DFF) e Roxo Meia-Noite (#240046),
/// inspirados no design do Spotify com tema escuro.
abstract final class AppColors {
  // ── Marca ──────────────────────────────────────────────
  static const Color lilac = Color(0xFFC77DFF);
  static const Color purple = Color(0xFF7B2FF7);
  static const Color deepPurple = Color(0xFF5A189A);
  static const Color midnightPurple = Color(0xFF240046);

  // ── Superfícies ────────────────────────────────────────
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF252540);
  static const Color card = Color(0xFF16162A);

  // ── Texto ──────────────────────────────────────────────
  static const Color onBackground = Color(0xFFE8E8F0);
  static const Color onSurface = Color(0xFFE0E0EC);
  static const Color onSurfaceVariant = Color(0xFFA0A0B8);
  static const Color onPrimary = Colors.white;

  // ── Utilidade ──────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ADE80);
  static const Color divider = Color(0xFF2A2A45);

  // ── Gradientes ─────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lilac, deepPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1040), background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient playerGradient = LinearGradient(
    colors: [midnightPurple, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceVariant, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
