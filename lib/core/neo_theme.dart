import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeoTheme {
  NeoTheme._();

  // ═══════════════════════════════════════════════════════════════
  // CORE BACKGROUND - OLED-grade deep black
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundDeep = Color(0xFF05070A);
  static const Color backgroundCard = Color(0xFF0A111C);
  static const Color backgroundElevated = Color(0xFF0D1520);
  static const Color backgroundSurface = Color(0xFF111B28);

  // ═══════════════════════════════════════════════════════════════
  // NEON SYSTEM - Primary illumination (Cyan)
  // Source → Intensity → Dispersion → Reflection → Dissipation
  // ═══════════════════════════════════════════════════════════════
  static const Color neonCyan = Color(0xFF00B7FF);
  static const Color neonCyanBright = Color(0xFF33C9FF);
  static const Color neonCyanDim = Color(0xFF005F8C);
  static const Color neonCyanFaint = Color(0xFF002A3D);

  // ═══════════════════════════════════════════════════════════════
  // METALLIC SYSTEM - Physical material simulation
  // ═══════════════════════════════════════════════════════════════
  static const Color metalLight = Color(0xFF2A3444);
  static const Color metalMid = Color(0xFF1A2230);
  static const Color metalDark = Color(0xFF0E1520);
  static const Color metalHighlight = Color(0xFF3D4D60);
  static const Color metalBezel = Color(0xFF162030);

  // ═══════════════════════════════════════════════════════════════
  // ALARM HIERARCHY - Functional color coding
  // Normal → Warning → Alert → Critical
  // ═══════════════════════════════════════════════════════════════
  static const Color statusNormal = Color(0xFF00E676);
  static const Color statusWarning = Color(0xFFFFEA00);
  static const Color statusAlert = Color(0xFFFF9100);
  static const Color statusCritical = Color(0xFFFF1744);

  // Legacy aliases
  static const Color normalGreen = statusNormal;
  static const Color warningYellow = statusWarning;
  static const Color criticalRed = statusCritical;

  // ═══════════════════════════════════════════════════════════════
  // GAUGE GRADIENT - Arc coloring
  // Spec §5: transição contínua AZUL → CIANO → VERDE → AMARELO →
  // LARANJA → VERMELHO (sem saltos). Faixas: 0-139 normal,
  // 140-179 alerta, 180-220 crítico.
  // ═══════════════════════════════════════════════════════════════
  static const Color gaugeBlue = Color(0xFF0066FF);
  static const Color gaugeCyan = Color(0xFF00E5FF);
  static const Color gaugeGreen = Color(0xFF00E676);
  static const Color gaugeYellow = Color(0xFFFFD600);
  static const Color gaugeOrange = Color(0xFFFF9100);
  static const Color gaugeRed = Color(0xFFFF1744);

  /// Paleta premium do arco — 6 cores interpoladas suavemente.
  static const List<Color> premiumArcColors = [
    gaugeBlue,
    gaugeCyan,
    gaugeGreen,
    gaugeYellow,
    gaugeOrange,
    gaugeRed,
  ];

  /// Paradas alinhadas às faixas funcionais do velocímetro
  /// (vermelho sólido a partir de ~180 km/h = 0.82 do arco).
  static const List<double> premiumArcStops = [
    0.0,
    0.16,
    0.34,
    0.52,
    0.70,
    0.82,
  ];

  // ═══════════════════════════════════════════════════════════════
  // GLASSMORPHISM - Multi-layer transparency
  // ═══════════════════════════════════════════════════════════════
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassBorderActive = Color(0x29FFFFFF);
  static const Color glassFillStart = Color(0x0DFFFFFF);
  static const Color glassFillMid = Color(0x08FFFFFF);
  static const Color glassFillEnd = Color(0x03FFFFFF);
  static const Color glassHighlight = Color(0x0AFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // NEEDLE SYSTEM - Pointer rendering
  // ═══════════════════════════════════════════════════════════════
  static const Color needleRed = Color(0xFFFF1744);
  static const Color needleRedBright = Color(0xFFFF4569);
  static const Color needleShadow = Color(0x99000000);
  static const Color needleTrail = Color(0x33FF1744);
  static const Color needleHalo = Color(0x1AFF1744);

  // ═══════════════════════════════════════════════════════════════
  // NEON NEEDLE SYSTEM - Agulha futurista ciano
  // ═══════════════════════════════════════════════════════════════
  static const Color needleNeon = Color(0xFF00B7FF);
  static const Color needleNeonBright = Color(0xFF4FD3FF);
  static const Color needleNeonCore = Color(0xFFE6FAFF);

  // ═══════════════════════════════════════════════════════════════
  // TEXT HIERARCHY - Typography colors
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFE8ECF0);
  static const Color textSecondary = Color(0xFF8A9BB0);
  static const Color textDim = Color(0xFF4A5568);
  static const Color textFaint = Color(0xFF2D3748);

  // ═══════════════════════════════════════════════════════════════
  // DEPTH & SHADOW
  // ═══════════════════════════════════════════════════════════════
  static const Color shadowDeep = Color(0x40000000);
  static const Color shadowMid = Color(0x20000000);
  static const Color shadowLight = Color(0x10000000);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS - Pre-built for Canvas usage
  // ═══════════════════════════════════════════════════════════════

  /// Metallic bezel gradient (concentric ring effect)
  static const List<Color> bezelGradient = [
    metalDark,
    metalLight,
    metalMid,
    metalDark,
  ];

  /// Hub metallic gradient
  static const List<Color> hubGradient = [
    metalMid,
    metalHighlight,
    metalLight,
    metalDark,
  ];

  /// Neon glow gradient (radial falloff)
  static const List<Color> neonGlowGradient = [
    neonCyan,
    neonCyanDim,
    neonCyanFaint,
    Colors.transparent,
  ];

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY - Orbitron with fallback
  // ═══════════════════════════════════════════════════════════════

  static TextStyle digitalFont({
    double size = 14,
    Color color = textPrimary,
    FontWeight weight = FontWeight.w700,
  }) {
    try {
      return GoogleFonts.orbitron(
        fontSize: size,
        color: color,
        fontWeight: weight,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Courier New',
        fontSize: size,
        color: color,
        fontWeight: FontWeight.bold,
      );
    }
  }

  static TextStyle labelFont({
    double size = 10,
    Color color = textDim,
    FontWeight weight = FontWeight.w400,
  }) {
    try {
      return GoogleFonts.orbitron(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: 1.5,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Courier New',
        fontSize: size,
        color: color,
        letterSpacing: 1.5,
      );
    }
  }

  static TextStyle unitFont({
    double size = 9,
    Color color = textDim,
  }) {
    try {
      return GoogleFonts.orbitron(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.0,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Courier New',
        fontSize: size,
        color: color,
      );
    }
  }
}
