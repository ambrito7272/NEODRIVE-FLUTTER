import 'package:flutter/material.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';
import 'package:neodrive_1/core/gauge_engine.dart';
import 'neo_gauge.dart';

/// Conta-giros NEODRIVE (RPM) — redline fixo, escala VW AP.
class Tachometer extends StatelessWidget {
  final double value;
  final double maxValue;
  final double redlineStart;
  final AlarmState alarmState;
  final GaugeSize size;
  final Duration animationDuration;

  const Tachometer({
    super.key,
    required this.value,
    this.maxValue = 7000,
    this.redlineStart = 6200,
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
      label: 'RPM',
      unit: 'rpm',
      majorTicks: 7,
      minorTicks: 5,
      decimals: 0,
      animationDuration: animationDuration,
    );
  }
}