import 'package:flutter/material.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';
import 'package:neodrive_1/core/gauge_engine.dart';
import 'neo_gauge.dart';

/// Velocímetro NEODRIVE (km/h) — wrapper do motor gráfico unificado.
class Speedometer extends StatelessWidget {
  final double value;
  final double maxValue;
  final double redlineStart;
  final AlarmState alarmState;
  final GaugeSize size;
  final Duration animationDuration;

  const Speedometer({
    super.key,
    required this.value,
    this.maxValue = 220,
    this.redlineStart = double.infinity,
    this.alarmState = AlarmState.normal,
    this.size = GaugeSize.large,
    this.animationDuration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return NeoGauge(
      value: value,
      minValue: 0,
      maxValue: maxValue,
      redlineStart: redlineStart,
      alarmState: alarmState,
      size: size,
      label: 'VELOCIDADE',
      unit: 'km/h',
      majorTicks: 11,
      minorTicks: 4,
      decimals: 0,
      animationDuration: animationDuration,
    );
  }
}