import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';

/// Tamanho hierárquico do instrumento (escala proporcional).
enum GaugeSize { large, medium, small }

/// Cor do arco em um dado progresso — interpolação contínua (spec §5).
///
/// Sem saltos: `Color.lerp` entre paradas adjacentes da paleta premium
/// AZUL → CIANO → VERDE → AMARELO → LARANJA → VERMELHO.
Color neonArcColorAt(
  double progress, {
  List<Color>? colors,
  List<double>? stops,
}) {
  final cs = colors ?? NeoTheme.premiumArcColors;
  final ss = stops ?? NeoTheme.premiumArcStops;
  if (cs.isEmpty) return NeoTheme.neonCyan;
  if (cs.length == 1) return cs.first;
  final p = progress.clamp(0.0, 1.0);
  if (p <= ss.first) return cs.first;
  if (p >= ss.last) return cs.last;
  for (var i = 0; i < ss.length - 1; i++) {
    if (p >= ss[i] && p <= ss[i + 1]) {
      final t = (p - ss[i]) / (ss[i + 1] - ss[i]);
      return Color.lerp(cs[i], cs[i + 1], t)!;
    }
  }
  return cs.last;
}

/// Configuração imutável de um relógio NEODRIVE.
///
/// Todos os valores de geometria são **fracionais do raio** — o mesmo
/// `GaugePainter` desenha com precisão milimétrica em 240×240 ou em 1920×1080.
class GaugeConfig {
  final double value;
  final double minValue;
  final double maxValue;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final String label;
  final String unit;
  final List<Color> arcColors;
  final List<double> arcStops;
  final int majorTicks;
  final int minorTicks;
  final double? redlineStart;
  final AlarmState alarmState;
  final bool showGlow;
  final double needleLength;
  final int decimals;
  final GaugeSize size;
  final double trailSweep;
  final double velocity;
  final bool showDigitalValue;
  final bool dynamicNeedleColor;

  const GaugeConfig({
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.startAngleDeg = 135,
    this.sweepAngleDeg = 270,
    this.label = '',
    this.unit = '',
    // Spec §5: paleta premium 6 cores, transição contínua.
    this.arcColors = NeoTheme.premiumArcColors,
    this.arcStops = NeoTheme.premiumArcStops,
    this.majorTicks = 10,
    this.minorTicks = 5,
    this.redlineStart,
    this.alarmState = AlarmState.normal,
    this.showGlow = true,
    this.needleLength = 0.84,
    this.decimals = 0,
    this.size = GaugeSize.large,
    this.trailSweep = 0.0,
    this.velocity = 0.0,
    this.showDigitalValue = true,
    // Spec §5: a cor acompanha o valor atual do ponteiro.
    this.dynamicNeedleColor = true,
  });

  double get valueClamped => value.clamp(minValue, maxValue);

  double get valueProgress => maxValue != minValue
      ? (valueClamped - minValue) / (maxValue - minValue)
      : 0.0;

  double get startAngleRad => startAngleDeg * math.pi / 180;

  double get sweepAngleRad => sweepAngleDeg * math.pi / 180;

  double get endAngleRad => startAngleRad + sweepAngleRad;

  double get needleAngleRad => startAngleRad + valueProgress * sweepAngleRad;

  GaugeConfig copyWith({
    double? value,
    double? minValue,
    double? maxValue,
    double? startAngleDeg,
    double? sweepAngleDeg,
    String? label,
    String? unit,
    List<Color>? arcColors,
    List<double>? arcStops,
    int? majorTicks,
    int? minorTicks,
    double? redlineStart,
    AlarmState? alarmState,
    bool? showGlow,
    double? needleLength,
    int? decimals,
    GaugeSize? size,
    double? trailSweep,
    double? velocity,
    bool? showDigitalValue,
    bool? dynamicNeedleColor,
  }) {
    return GaugeConfig(
      value: value ?? this.value,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      startAngleDeg: startAngleDeg ?? this.startAngleDeg,
      sweepAngleDeg: sweepAngleDeg ?? this.sweepAngleDeg,
      label: label ?? this.label,
      unit: unit ?? this.unit,
      arcColors: arcColors ?? this.arcColors,
      arcStops: arcStops ?? this.arcStops,
      majorTicks: majorTicks ?? this.majorTicks,
      minorTicks: minorTicks ?? this.minorTicks,
      redlineStart: redlineStart ?? this.redlineStart,
      alarmState: alarmState ?? this.alarmState,
      showGlow: showGlow ?? this.showGlow,
      needleLength: needleLength ?? this.needleLength,
      decimals: decimals ?? this.decimals,
      size: size ?? this.size,
      trailSweep: trailSweep ?? this.trailSweep,
      velocity: velocity ?? this.velocity,
      showDigitalValue: showDigitalValue ?? this.showDigitalValue,
      dynamicNeedleColor:
          dynamicNeedleColor ?? this.dynamicNeedleColor,
    );
  }
}

/// Motor de renderização do relógio — 100% `CustomPainter`/`Canvas`.
///
/// Nenhuma imagem `.png`/`.jpg`: toda a profundidade (anel metálico, face,
/// arco neon 6 cores, escala iluminada, ponteiro multi-camada, cubo central,
/// reflexo de vidro) é vetorial.
///
/// Ordem de pintura (trás → frente), conforme spec §8:
/// 0. Face profunda + anéis internos     1. Bisel metálico
/// 2. Glow ambiente                      3. Arco de fundo (escala completa, apagado)
/// 4. Arco iluminado (SweepGradient 6 cores)
/// 5. Glow neon do arco                  6. Redline
/// 7. Escala iluminada (ticks + números)
/// 8. Trail/cometa luminoso (integrado ao arco)
/// 9. Ponteiro multi-camada              10. Cubo central
/// 11. Leitura digital + unidade         12. Rótulo
/// 13. Reflexo de vidro (acabamento)
class GaugePainter extends CustomPainter {
  final GaugeConfig config;

  GaugePainter({required this.config});

  double _dim(double fraction, double radius) => fraction * radius;

  // ───────────────────────────────────────────────────────────────
  // MÉTODO PRINCIPAL
  // ───────────────────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.92;
    if (radius <= 0) return;

    _paintBase(canvas, center, radius);
    _paintBezel(canvas, center, radius);
    if (config.showGlow) _paintAmbientGlow(canvas, center, radius);
    _paintArcBackground(canvas, center, radius);
    _paintArcLit(canvas, center, radius);
    if (config.showGlow) _paintArcGlow(canvas, center, radius);
    _paintRedline(canvas, center, radius);
    _paintScale(canvas, center, radius);
    _paintNeedleTrail(canvas, center, radius);
    _paintNeedle(canvas, center, radius);
    _paintHub(canvas, center, radius);
    if (config.showDigitalValue) _paintDigital(canvas, center, radius);
    _paintLabel(canvas, center, radius);
    if (config.showGlow) _paintGlass(canvas, center, radius);
  }

  // ───────────────────────────────────────────────────────────────
  // UTILITÁRIOS DE COR
  // ───────────────────────────────────────────────────────────────
  Color _colorAtProgress(double progress) => neonArcColorAt(
        progress,
        colors: config.arcColors,
        stops: config.arcStops,
      );

  Color _alarmAccent() {
    switch (config.alarmState) {
      case AlarmState.warning:
        return NeoTheme.statusWarning;
      case AlarmState.critical:
        return NeoTheme.statusCritical;
      case AlarmState.normal:
        return NeoTheme.neonCyan;
    }
  }

  String _formatTickValue(double value) {
    if (value == value.roundToDouble() && value.abs() < 10000) {
      return value.toInt().toString();
    }
    if (value.abs() < 10) return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 0 — FACE PROFUNDA + ANÉIS INTERNOS SUBTIS (spec §8)
  // ───────────────────────────────────────────────────────────────
  void _paintBase(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            NeoTheme.backgroundElevated,
            NeoTheme.backgroundCard,
            NeoTheme.backgroundDeep,
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // Vinco interno de profundidade (anel concêntrico escuro)
    canvas.drawCircle(
      center,
      radius * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.012, radius)
        ..color = NeoTheme.backgroundDeep.withValues(alpha: 0.55),
    );

    // Anel sutil interno (profundidade extra, quase invisível)
    canvas.drawCircle(
      center,
      radius * 0.52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.006, radius)
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.05),
    );
    canvas.drawCircle(
      center,
      radius * 0.90,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.003, radius)
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.04),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 1 — BISEL METÁLICO
  // ───────────────────────────────────────────────────────────────
  void _paintBezel(Canvas canvas, Offset center, double radius) {
    final bw = _dim(0.022, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius - bw / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bw
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          colors: NeoTheme.bezelGradient,
          stops: [0.0, 0.25, 0.5, 0.75],
        ).createShader(rect),
    );

    // Brilho superior (reflexo de luz)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - bw / 2),
      math.pi * 1.15,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.004, radius)
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.55),
    );

    canvas.drawCircle(
      center,
      radius - bw,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = NeoTheme.metalDark.withValues(alpha: 0.4),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 2 — GLOW AMBIENTE (reage ao estado de alarme)
  // ───────────────────────────────────────────────────────────────
  void _paintAmbientGlow(Canvas canvas, Offset center, double radius) {
    final gc = _alarmAccent();
    canvas.drawCircle(
      center,
      radius + _dim(0.02, radius),
      Paint()
        ..color = gc.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.08, radius)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, _dim(0.12, radius)),
    );
    canvas.drawCircle(
      center,
      radius - _dim(0.01, radius),
      Paint()
        ..color = gc.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.015, radius)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.06, radius)),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 3 — ARCO DE FUNDO (escala completa, apagado — spec §4:
  // a escala NUNCA é escondida; o trecho percorrido fica mais claro)
  // ───────────────────────────────────────────────────────────────
  void _paintArcBackground(Canvas canvas, Offset center, double radius) {
    final arcR = radius - _dim(0.085, radius);
    final sw = _dim(0.048, radius);
    final rect = Rect.fromCircle(center: center, radius: arcR);

    canvas.drawArc(
      rect,
      config.startAngleRad,
      config.sweepAngleRad,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: config.startAngleRad,
          endAngle: config.endAngleRad,
          colors: config.arcColors
              .map((c) => c.withValues(alpha: 0.16))
              .toList(),
          stops: config.arcStops,
        ).createShader(rect),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 4 — ARCO ILUMINADO (SweepGradient 6 cores até o valor)
  // ───────────────────────────────────────────────────────────────
  void _paintArcLit(Canvas canvas, Offset center, double radius) {
    if (config.valueProgress <= 0) return;
    final arcR = radius - _dim(0.085, radius);
    final sw = _dim(0.048, radius);
    final rect = Rect.fromCircle(center: center, radius: arcR);
    final sweep = config.sweepAngleRad * config.valueProgress;

    canvas.drawArc(
      rect,
      config.startAngleRad,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: config.startAngleRad,
          endAngle: config.endAngleRad,
          colors: config.arcColors,
          stops: config.arcStops,
        ).createShader(rect),
    );

    // Ponta do arco (headlight) — brilho concentrado na frente do progresso
    final headAngle = config.startAngleRad + sweep;
    final headR = arcR - sw / 2;
    canvas.drawCircle(
      Offset(
        center.dx + headR * math.cos(headAngle),
        center.dy + headR * math.sin(headAngle),
      ),
      sw * 1.5,
      Paint()
        ..color = _colorAtProgress(config.valueProgress)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sw),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 5 — GLOW NEON DO ARCO
  // ───────────────────────────────────────────────────────────────
  void _paintArcGlow(Canvas canvas, Offset center, double radius) {
    if (config.valueProgress <= 0) return;
    final arcR = radius - _dim(0.085, radius);
    final sw = _dim(0.048, radius);
    final sweep = config.sweepAngleRad * config.valueProgress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      config.startAngleRad,
      sweep,
      false,
      Paint()
        ..color = _colorAtProgress(config.valueProgress).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw + _dim(0.035, radius)
        ..strokeCap = StrokeCap.round
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, math.max(6.0, radius * 0.05)),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 6 — REDLINE (segmento vermelho fixo)
  // ───────────────────────────────────────────────────────────────
  void _paintRedline(Canvas canvas, Offset center, double radius) {
    if (config.redlineStart == null) return;
    final progress = (config.redlineStart! - config.minValue) /
        (config.maxValue - config.minValue);
    if (progress <= 0 || progress >= 1) return;
    final rlAngle = config.startAngleRad + progress * config.sweepAngleRad;
    final arcR = radius - _dim(0.085, radius);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      rlAngle,
      config.endAngleRad - rlAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.048, radius)
        ..strokeCap = StrokeCap.round
        ..color = NeoTheme.gaugeRed.withValues(alpha: 0.75),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 7 — ESCALA ILUMINADA (ticks + números)
  // Spec §4: a escala permanece visível; o trecho percorrido recebe
  // aumento de brilho, saturação e intensidade.
  // ───────────────────────────────────────────────────────────────
  void _paintScale(Canvas canvas, Offset center, double radius) {
    final tickOuter = radius - _dim(0.125, radius);
    final majorLen = _dim(0.095, radius);
    final minorLen = _dim(0.05, radius);
    final majorW = math.max(1.2, _dim(0.014, radius));
    final minorW = math.max(0.6, _dim(0.007, radius));
    final needleAngle = config.needleAngleRad;
    final totalMinor = config.majorTicks * config.minorTicks;

    for (var i = 0; i <= totalMinor; i++) {
      final progress = i / totalMinor;
      final angle = config.startAngleRad + progress * config.sweepAngleRad;
      final isMajor = i % config.minorTicks == 0;
      final len = isMajor ? majorLen : minorLen;

      final outerPt = Offset(
        center.dx + tickOuter * math.cos(angle),
        center.dy + tickOuter * math.sin(angle),
      );
      final innerPt = Offset(
        center.dx + (tickOuter - len) * math.cos(angle),
        center.dy + (tickOuter - len) * math.sin(angle),
      );

      final isLit = angle <= needleAngle;

      Color tickColor;
      if (isLit) {
        tickColor = _colorAtProgress(progress);
        if (isMajor) tickColor = Color.lerp(tickColor, Colors.white, 0.22)!;
      } else {
        // Nunca apaga: escala visível em tom neutro
        tickColor = NeoTheme.textSecondary.withValues(alpha: 0.30);
      }

      canvas.drawLine(
        innerPt,
        outerPt,
        Paint()
          ..color = tickColor
          ..strokeWidth = isMajor ? majorW : minorW
          ..strokeCap = StrokeCap.round,
      );

      // Glow dos ticks maiores iluminados
      if (isMajor && isLit && config.size != GaugeSize.small) {
        canvas.drawLine(
          innerPt,
          outerPt,
          Paint()
            ..color = tickColor.withValues(alpha: 0.35)
            ..strokeWidth = majorW + _dim(0.018, radius)
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.016, radius)),
        );
      }

      if (isMajor && config.size != GaugeSize.small) {
        final labelR = tickOuter - len - _dim(0.11, radius);
        _paintTickLabel(
          canvas,
          center,
          labelR,
          angle,
          i,
          isLit,
          progress,
        );
      }
    }
  }

  void _paintTickLabel(
    Canvas canvas,
    Offset center,
    double labelRadius,
    double angle,
    int tickIndex,
    bool lit,
    double progress,
  ) {
    final labelValue = config.minValue +
        (tickIndex / config.majorTicks) * (config.maxValue - config.minValue);
    // Números GRANDES, nítidos e permanentemente legíveis (spec §4)
    final fontSize = math.max(7.5, _dim(0.075, labelRadius));

    final color = lit
        ? Color.lerp(_colorAtProgress(progress), NeoTheme.textPrimary, 0.30)!
        : NeoTheme.textSecondary.withValues(alpha: 0.30);

    final tp = TextPainter(
      text: TextSpan(
        text: _formatTickValue(labelValue),
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontFamilyFallback: const ['Courier New'],
          fontSize: fontSize,
          color: color,
          fontWeight: lit ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: fontSize * 0.04,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        center.dx + labelRadius * math.cos(angle) - tp.width / 2,
        center.dy + labelRadius * math.sin(angle) - tp.height / 2,
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 8 — TRAIL / COMETA LUMINOSO (spec §7)
  // Integrado ao arco: mais intenso próximo ao ponteiro, desaparece
  // progressivamente para trás. Segue o movimento real do ponteiro.
  // ───────────────────────────────────────────────────────────────
  void _paintNeedleTrail(Canvas canvas, Offset center, double radius) {
    final progress = config.valueProgress;
    if (progress <= 0.02) return;
    final arcR = radius - _dim(0.085, radius);
    final needleAngle = config.needleAngleRad;
    final sweep = needleAngle - config.startAngleRad;
    final tailColor = _colorAtProgress(progress);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Camada difusa (corpo do rastro)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      config.startAngleRad,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.05, radius)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: config.startAngleRad,
          endAngle: needleAngle,
          colors: [
            tailColor.withValues(alpha: 0.0),
            tailColor.withValues(alpha: 0.18),
          ],
        ).createShader(rect),
    );

    // Camada nítida (núcleo do rastro, mais forte perto do ponteiro)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      config.startAngleRad,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.034, radius)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: config.startAngleRad,
          endAngle: needleAngle,
          colors: [
            tailColor.withValues(alpha: 0.0),
            tailColor.withValues(alpha: 0.42),
          ],
        ).createShader(rect),
    );

    // Esteira curta logo atrás do ponteiro (sensação de movimento)
    final wakeSweep = math.min(0.22, sweep * 0.5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcR),
      needleAngle - wakeSweep,
      wakeSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.026, radius)
        ..strokeCap = StrokeCap.round
        ..color = tailColor.withValues(alpha: 0.32)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, math.max(4.0, radius * 0.03)),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 9 — PONTEIRO MULTI-CAMADA (spec §6)
  // 1 corpo principal → 2 gradiente de cor → 3 núcleo/estrutura →
  // 4 halo luminoso → 5 brilho externo → 6 rastro (já desenhado).
  // A cor acompanha a posição/valor atual do ponteiro (spec §5).
  // ───────────────────────────────────────────────────────────────
  void _paintNeedle(Canvas canvas, Offset center, double radius) {
    final angle = config.needleAngleRad;
    final needleLen = radius * config.needleLength;
    final counterLen = radius * 0.10;
    final baseHalf = _dim(0.028, radius);
    final counterHalf = _dim(0.020, radius);

    final perpX = math.cos(angle + math.pi / 2);
    final perpY = math.sin(angle + math.pi / 2);
    final dirX = math.cos(angle);
    final dirY = math.sin(angle);

    final tipPt =
        Offset(center.dx + needleLen * dirX, center.dy + needleLen * dirY);
    final baseL =
        Offset(center.dx + perpX * baseHalf, center.dy + perpY * baseHalf);
    final baseR =
        Offset(center.dx - perpX * baseHalf, center.dy - perpY * baseHalf);

    final needlePath = Path()
      ..moveTo(baseL.dx, baseL.dy)
      ..lineTo(tipPt.dx, tipPt.dy)
      ..lineTo(baseR.dx, baseR.dy)
      ..close();

    final cwTip = Offset(
        center.dx - counterLen * dirX, center.dy - counterLen * dirY);
    final cwL =
        Offset(center.dx + perpX * counterHalf, center.dy + perpY * counterHalf);
    final cwR = Offset(
        center.dx - perpX * counterHalf, center.dy - perpY * counterHalf);

    final counterPath = Path()
      ..moveTo(cwL.dx, cwL.dy)
      ..lineTo(cwTip.dx, cwTip.dy)
      ..lineTo(cwR.dx, cwR.dy)
      ..close();

    // ── COR DINÂMICA DO PONTEIRO (acompanha o valor) ──
    final needleColor = config.dynamicNeedleColor
        ? _colorAtProgress(config.valueProgress)
        : NeoTheme.needleRed;
    final needleBright = Color.lerp(needleColor, Colors.white, 0.35)!;
    final needleCore = Color.lerp(needleColor, Colors.white, 0.72)!;

    // 5) BRILHO EXTERNO — halo largo ao redor do ponteiro
    canvas.drawPath(
      needlePath,
      Paint()
        ..color = needleColor.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.055, radius)),
    );

    // 1+2) SOMBRA 3D (preta, desfocada, deslocada) e CORPO
    final shadowOffset = Offset(_dim(0.006, radius), _dim(0.006, radius));
    final shadowPaint = Paint()
      ..color = NeoTheme.needleShadow
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2.0, radius * 0.02));
    canvas.drawPath(needlePath.shift(shadowOffset), shadowPaint);
    canvas.drawPath(counterPath.shift(shadowOffset), shadowPaint);

    final needleGradRect = Rect.fromPoints(baseL, tipPt);
    canvas.drawPath(
      needlePath,
      Paint()
        ..shader = LinearGradient(
          colors: [needleColor, needleBright, needleCore],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(needleGradRect),
    );
    canvas.drawPath(
      counterPath,
      Paint()..shader = LinearGradient(
        colors: [needleColor, needleBright],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromPoints(cwTip, baseL)),
    );

    // 3) NÚCLEO / ESTRUTURA — espinha luminosa + arestas
    final spinePaint = Paint()
      ..color = needleCore.withValues(alpha: 0.85)
      ..strokeWidth = math.max(0.8, _dim(0.006, radius))
      ..strokeCap = StrokeCap.round;
    final spineBase = Offset(
      center.dx + perpX * baseHalf * 0.25,
      center.dy + perpY * baseHalf * 0.25,
    );
    canvas.drawLine(spineBase, tipPt, spinePaint);

    // Arestas estruturais (fios de luz nas bordas)
    final edgePaint = Paint()
      ..color = needleCore.withValues(alpha: 0.18)
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx + perpX * baseHalf * 0.8, center.dy + perpY * baseHalf * 0.8),
      tipPt,
      edgePaint,
    );

    // 4) HALO LUMINOSO na ponta
    canvas.drawCircle(
      tipPt,
      _dim(0.014, radius),
      Paint()
        ..color = needleBright.withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.022, radius)),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 10 — CUBO CENTRAL METÁLICO
  // ───────────────────────────────────────────────────────────────
  void _paintHub(Canvas canvas, Offset center, double radius) {
    final hubR = _dim(0.105, radius);
    final innerR = hubR * 0.64;
    final dotR = hubR * 0.20;

    canvas.drawCircle(
      center,
      hubR,
      Paint()
        ..shader = const RadialGradient(
          colors: NeoTheme.hubGradient,
          stops: [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: hubR)),
    );

    canvas.drawCircle(
      center,
      hubR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = NeoTheme.metalHighlight.withValues(alpha: 0.45),
    );

    canvas.drawCircle(center, innerR, Paint()..color = NeoTheme.backgroundDeep);

    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = _alarmAccent().withValues(alpha: 0.4),
    );

    canvas.drawCircle(center, dotR, Paint()..color = _alarmAccent());
    canvas.drawCircle(
      center,
      dotR + _dim(0.008, radius),
      Paint()
        ..color = _alarmAccent().withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.016, radius)),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 11 — LEITURA DIGITAL + UNIDADE
  // ───────────────────────────────────────────────────────────────
  void _paintDigital(Canvas canvas, Offset center, double radius) {
    final valueStr = config.value.toStringAsFixed(config.decimals);
    final fontSize = _dim(0.24, radius);
    final valueY = center.dy + radius * 0.16;

    // Halo de fundo
    canvas.drawCircle(
      Offset(center.dx, valueY + fontSize * 0.3),
      fontSize * 0.55,
      Paint()
        ..color = _alarmAccent().withValues(alpha: 0.05)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _dim(0.1, radius)),
    );

    // Glow (texto desfocado)
    final glowTp = TextPainter(
      text: TextSpan(
        text: valueStr,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontFamilyFallback: const ['Courier New'],
          fontSize: fontSize,
          color: _alarmAccent().withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    glowTp.paint(canvas, Offset(center.dx - glowTp.width / 2, valueY));

    // Texto principal
    final mainTp = TextPainter(
      text: TextSpan(
        text: valueStr,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontFamilyFallback: const ['Courier New'],
          fontSize: fontSize,
          color: _alarmAccent(),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    mainTp.paint(canvas, Offset(center.dx - mainTp.width / 2, valueY));

    if (config.unit.isNotEmpty && config.size != GaugeSize.small) {
      final unitTp = TextPainter(
        text: TextSpan(
          text: config.unit,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontFamilyFallback: const ['Courier New'],
            fontSize: fontSize * 0.30,
            color: NeoTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      unitTp.paint(
        canvas,
        Offset(
          center.dx - unitTp.width / 2,
          valueY + mainTp.height + _dim(0.012, radius),
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 12 — RÓTULO (nome do instrumento)
  // ───────────────────────────────────────────────────────────────
  void _paintLabel(Canvas canvas, Offset center, double radius) {
    if (config.label.isEmpty) return;
    final fontSize = math.max(7.0, _dim(0.07, radius));
    final tp = TextPainter(
      text: TextSpan(
        text: config.label,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontFamilyFallback: const ['Courier New'],
          fontSize: fontSize,
          color: NeoTheme.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: fontSize * 0.16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy + radius * 0.40),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // LAYER 13 — REFLEXO DE VIDRO (acabamento, spec §8)
  // ───────────────────────────────────────────────────────────────
  void _paintGlass(Canvas canvas, Offset center, double radius) {
    final glassR = radius * 0.80;
    final rect = Rect.fromCircle(center: center, radius: glassR);
    canvas.drawArc(
      rect,
      math.pi * 1.22,
      math.pi * 0.42,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _dim(0.055, radius)
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: math.pi * 1.22,
          endAngle: math.pi * 1.64,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.045),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // REPAINT DIRECIONADO
  // ───────────────────────────────────────────────────────────────
  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.config.value != config.value ||
        oldDelegate.config.alarmState != config.alarmState ||
        oldDelegate.config.trailSweep != config.trailSweep ||
        oldDelegate.config.velocity != config.velocity;
  }
}

/// Alias de compatibilidade (o nome histórico do motor de renderização).
typedef GaugeEngine = GaugePainter;