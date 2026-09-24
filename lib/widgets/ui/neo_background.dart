import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:neodrive_1/core/neo_theme.dart';

/// Fundo futurístico do painel NEODRIVE — grade HUD em perspectiva,
/// horizonte neon ciano, scanlines de CRT e vinheta.
///
/// 100% `CustomPainter`, estático (`shouldRepaint => false`), não usa
/// imagens. Desenhado em camadas:
/// 1. Radial escuro (base OLED)
/// 2. Horizonte neon (linha de luz ciano)
/// 3. Grade em perspectiva (chão HUD)
/// 4. Scanlines horizontais sutis
/// 5. Vinheta final
class NeoBackground extends StatelessWidget {
  const NeoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NeoBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _NeoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    // 1 ─ Base radial escura (centro luminoso no topo)
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.7),
          radius: 1.4,
          colors: [
            NeoTheme.backgroundElevated.withValues(alpha: 0.9),
            NeoTheme.backgroundCard,
            NeoTheme.backgroundDeep,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bounds),
    );

    // 2 ─ Horizonte neon ciano
    final horizonY = size.height * 0.24;
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          NeoTheme.neonCyan.withValues(alpha: 0.45),
          NeoTheme.neonCyanDim.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, horizonY - 1.5, size.width, 3));
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 1.5, size.width, 3),
      horizonPaint,
    );
    // Brilho difuso abaixo do horizonte
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height * 0.05),
      Paint()
        ..color = NeoTheme.neonCyan.withValues(alpha: 0.05)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(6.0, size.height * 0.03),
        ),
    );

    // 3 ─ Grade HUD em perspectiva (ponto de fuga no centro)
    final vp = Offset(size.width / 2, horizonY);
    final grid = Paint()
      ..color = NeoTheme.neonCyan.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Linhas radiais do ponto de fuga
    for (var i = 0; i <= 14; i++) {
      final t = (i - 7) / 7;
      final bottomX = size.width / 2 + t * size.width * 0.55;
      canvas.drawLine(vp, Offset(bottomX, size.height), grid);
    }

    // Linhas horizontais do chão (espaçamento exponencial)
    for (var i = 1; i <= 9; i++) {
      final t = (math.pow(1.14, i).toDouble() - 1) /
          (math.pow(1.14, 9).toDouble() - 1);
      final y = horizonY + t * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // 4 ─ Scanlines de CRT
    final scan = Paint()..color = Colors.white.withValues(alpha: 0.02);
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
    }

    // 5 ─ Vinheta final
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Colors.transparent,
            Colors.transparent,
            NeoTheme.backgroundDeep.withValues(alpha: 0.55),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}