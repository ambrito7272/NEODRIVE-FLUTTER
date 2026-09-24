import 'package:flutter/material.dart';
import 'package:neodrive_1/core/neo_theme.dart';

/// COMBUSTÍVEL — único indicador LINEAR do sistema (prompt mestre §13).
///
/// NÃO é um `LinearProgressIndicator`/`Container` genérico: é uma barra
/// gráfica própria (CustomPainter) com trilho em recesso (profundidade),
/// preenchimento com gradiente contínuo, glow neon, halo, marcações de
/// segmento, letras **E** / **F** legíveis e animação de reserva.
///
/// Estado de reserva: cor muda progressivamente para âmbar/vermelho e um
/// pulso luminoso destaca a barra (preparado para alerta futuro, §23).
class FuelBar extends StatefulWidget {
  final double level;
  final double reserveThreshold;
  final double min;
  final double max;
  final Duration animationDuration;

  const FuelBar({
    super.key,
    required this.level,
    this.reserveThreshold = 15,
    this.min = 0,
    this.max = 100,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<FuelBar> createState() => _FuelBarState();
}

class _FuelBarState extends State<FuelBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late bool _reserve;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _reserve = _inReserve(widget.level);
    if (_reserve) _pulse.repeat(reverse: true);
  }

  bool _inReserve(double level) => level <= widget.reserveThreshold;

  @override
  void didUpdateWidget(covariant FuelBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reserve = _inReserve(widget.level);
    if (reserve && !_reserve) {
      _pulse.repeat(reverse: true);
    } else if (!reserve && _reserve) {
      _pulse.stop();
      _pulse.value = 0;
    }
    _reserve = reserve;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.max != widget.min
        ? ((widget.level.clamp(widget.min, widget.max) - widget.min) /
                (widget.max - widget.min))
            .clamp(0.0, 1.0)
        : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress),
      duration: widget.animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: FuelBarPainter(
              progress: animated,
              reserve: _reserve,
              pulse: _pulse.value,
            ),
          ),
        );
      },
    );
  }
}

/// Desenho vetorial da barra de combustível.
///
/// Layout: [E] ▸▸▸ barra ▸▸▸ [F]
/// Ordens de pintura: halo → trilho (recesso) → marcações → preenchimento
/// (glow + gradiente + reflexo) → letras E/F.
class FuelBarPainter extends CustomPainter {
  final double progress;
  final bool reserve;
  final double pulse;

  const FuelBarPainter({
    required this.progress,
    required this.reserve,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    if (h <= 0 || size.width <= 0) return;

    final accent = reserve ? NeoTheme.statusWarning : NeoTheme.neonCyan;
    final trackH = h * 0.42;
    final trackTop = (h - trackH) / 2;
    final letterGap = h * 1.15;
    final barWidth = size.width - letterGap * 2;
    if (barWidth <= 0) return;

    final barRect = Rect.fromLTWH(letterGap, trackTop, barWidth, trackH);
    final radius = Radius.circular(trackH / 2);
    final barRRect = RRect.fromRectAndRadius(barRect, radius);

    // 1) HALO — brilho difuso ao redor da barra (reage ao pulso de reserva)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        barRect.inflate(h * 0.16),
        Radius.circular(trackH),
      ),
      Paint()
        ..color = accent.withValues(alpha: 0.10 + pulse * 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.22),
    );

    // 2) TRILHO EM RECESSO — profundidade
    canvas.drawRRect(
      barRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NeoTheme.backgroundDeep,
            NeoTheme.backgroundCard,
            NeoTheme.backgroundDeep,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(barRect),
    );

    // Vinco metálico do trilho
    canvas.drawRRect(
      barRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.30),
    );
    // Sombra interna inferior
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        barRect.deflate(trackH * 0.22),
        Radius.circular(trackH),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = NeoTheme.shadowDeep.withValues(alpha: 0.6),
    );

    // 3) MARCAÇÕES DE SEGMENTO (hierarquia da escala)
    const segments = 8;
    final markPaint = Paint()
      ..color = NeoTheme.textDim.withValues(alpha: 0.22)
      ..strokeWidth = 1.0;
    for (var i = 1; i < segments; i++) {
      final x = barRect.left + barRect.width * (i / segments);
      canvas.drawLine(
        Offset(x, barRect.top + trackH * 0.22),
        Offset(x, barRect.bottom - trackH * 0.22),
        markPaint,
      );
    }

    // 4) PREENCHIMENTO PROPORCIONAL — gradiente + glow + reflexo
    final fillW = barRect.width * progress.clamp(0.0, 1.0);
    if (fillW > 0) {
      final fillRect = Rect.fromLTWH(
        barRect.left,
        barRect.top,
        fillW,
        barRect.height,
      );
      final fillRRect = RRect.fromRectAndRadius(fillRect, radius);

      final fillColors = reserve
          ? const [NeoTheme.statusAlert, NeoTheme.statusCritical]
          : const [
              NeoTheme.neonCyanDim,
              NeoTheme.neonCyanBright,
              NeoTheme.statusNormal,
            ];
      final fillStops = reserve ? const [0.0, 1.0] : const [0.0, 0.45, 1.0];

      // Glow do preenchimento (forte em reserva com pulso)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect.inflate(trackH * 0.55),
          Radius.circular(trackH),
        ),
        Paint()
          ..color = accent.withValues(alpha: 0.30 + pulse * 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.16),
      );

      // Corpo com gradiente contínuo
      canvas.drawRRect(
        fillRRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: fillColors,
            stops: fillStops,
          ).createShader(barRect),
      );

      // Reflexo de vidro (linha clara no topo do preenchimento)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect.deflate(trackH * 0.16),
          Radius.circular(trackH),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = Colors.white.withValues(alpha: 0.14),
      );

      // Ponta luminosa (frente do preenchimento)
      canvas.drawCircle(
        Offset(fillRect.right, barRect.center.dy),
        trackH * 0.30,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, trackH * 0.4),
      );
    }

    // 5) LETRAS E / F — legíveis, hierarquia clara
    _paintLetter(canvas, 'E', barRect.left, barRect.center.dy, h,
        reserve ? NeoTheme.statusCritical : NeoTheme.textSecondary);
    _paintLetter(canvas, 'F', barRect.right, barRect.center.dy, h,
        NeoTheme.neonCyanBright);
  }

  void _paintLetter(
    Canvas canvas,
    String letter,
    double anchorX,
    double centerY,
    double height,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontFamilyFallback: const ['Courier New'],
          fontSize: height * 0.46,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = letter == 'E'
        ? anchorX - height * 0.35 - tp.width
        : anchorX + height * 0.35;
    tp.paint(canvas, Offset(dx, centerY - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant FuelBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.reserve != reserve ||
        oldDelegate.pulse != pulse;
  }
}