import 'package:flutter/material.dart';
import 'package:neodrive_1/core/gauge_engine.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';

/// Instrumento circular NEODRIVE — 100% vetorial e auto-responsivo.
///
/// O ponteiro "voa" com `TweenAnimationBuilder` + `Curves.easeOutCubic`
/// (nenhum `setState`), o readout digital usa `FittedBox(contain)` para
/// escalar junto com o tamanho real do medidor (240px ou 4K), e o arco
/// neon de 6 cores acompanha o valor atual.
class NeoGauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double redlineStart;
  final AlarmState alarmState;
  final GaugeSize size;
  final String label;
  final String unit;
  final int majorTicks;
  final int minorTicks;
  final int decimals;
  final Duration animationDuration;
  final double readoutSize;
  final bool showReadout;

  const NeoGauge({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 220,
    this.redlineStart = double.infinity,
    this.alarmState = AlarmState.normal,
    this.size = GaugeSize.large,
    this.label = '',
    this.unit = '',
    this.majorTicks = 11,
    this.minorTicks = 4,
    this.decimals = 0,
    this.animationDuration = const Duration(milliseconds: 700),
    this.readoutSize = 110,
    this.showReadout = true,
  });

  Color get _accent {
    switch (alarmState) {
      case AlarmState.warning:
        return NeoTheme.statusWarning;
      case AlarmState.critical:
        return NeoTheme.statusCritical;
      case AlarmState.normal:
        return NeoTheme.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, animated, child) {
            final config = GaugeConfig(
              value: animated,
              minValue: minValue,
              maxValue: maxValue,
              label: label,
              unit: unit,
              majorTicks: majorTicks,
              minorTicks: minorTicks,
              decimals: decimals,
              redlineStart: redlineStart.isFinite ? redlineStart : null,
              alarmState: alarmState,
              size: size,
              showDigitalValue: false,
            );

            final clamped = animated.clamp(minValue, maxValue);
            final progress = maxValue != minValue
                ? (clamped - minValue) / (maxValue - minValue)
                : 0.0;
            final readoutColor = alarmState == AlarmState.normal
                ? neonArcColorAt(progress)
                : _accent;

            return Stack(
              alignment: Alignment.center,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: GaugePainter(config: config),
                    size: Size.infinite,
                  ),
                ),
                if (showReadout)
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.55,
                      heightFactor: 0.42,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              animated.toStringAsFixed(decimals),
                              style: NeoTheme.digitalFont(
                                size: readoutSize,
                                color: readoutColor,
                                weight: FontWeight.bold,
                              ),
                            ),
                            if (unit.isNotEmpty)
                              Text(
                                unit.toUpperCase(),
                                style: NeoTheme.unitFont(
                                  size: readoutSize * 0.24,
                                  color: NeoTheme.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}