import 'alarm_state.dart';

/// Limites de alarme (warning / critical) de uma métrica.
///
/// Valores `±infinity` indicam que aquele limite não está ativo
/// (ex.: mínimos de temperatura).
class AlarmThresholds {
  final double warningMin;
  final double warningMax;
  final double criticalMin;
  final double criticalMax;

  const AlarmThresholds({
    this.warningMin = double.negativeInfinity,
    this.warningMax = double.infinity,
    this.criticalMin = double.negativeInfinity,
    this.criticalMax = double.infinity,
  });

  AlarmThresholds copyWith({
    double? warningMin,
    double? warningMax,
    double? criticalMin,
    double? criticalMax,
  }) {
    return AlarmThresholds(
      warningMin: warningMin ?? this.warningMin,
      warningMax: warningMax ?? this.warningMax,
      criticalMin: criticalMin ?? this.criticalMin,
      criticalMax: criticalMax ?? this.criticalMax,
    );
  }

  AlarmState evaluate(double value) {
    if (value < criticalMin || value > criticalMax) return AlarmState.critical;
    if (value < warningMin || value > warningMax) return AlarmState.warning;
    return AlarmState.normal;
  }

  Map<String, double> toMap() => {
        'wMin': warningMin,
        'wMax': warningMax,
        'cMin': criticalMin,
        'cMax': criticalMax,
      };

  factory AlarmThresholds.fromMap(Map<String, dynamic> map) {
    double g(String key, double fallback) =>
        (map[key] as num?)?.toDouble() ?? fallback;
    return AlarmThresholds(
      warningMin: g('wMin', double.negativeInfinity),
      warningMax: g('wMax', double.infinity),
      criticalMin: g('cMin', double.negativeInfinity),
      criticalMax: g('cMax', double.infinity),
    );
  }
}

/// Configuração completa de alarmes do cluster.
class AlarmConfig {
  final AlarmThresholds oilPressure;
  final AlarmThresholds coolantTemp;
  final AlarmThresholds batteryVoltage;
  final AlarmThresholds current;
  final AlarmThresholds vacuum;
  final AlarmThresholds lambdaAfr;
  final AlarmThresholds rpm;

  const AlarmConfig({
    required this.oilPressure,
    required this.coolantTemp,
    required this.batteryVoltage,
    required this.current,
    required this.vacuum,
    required this.lambdaAfr,
    required this.rpm,
  });

  factory AlarmConfig.defaults() => const AlarmConfig(
        oilPressure: AlarmThresholds(
          warningMin: 1.5,
          criticalMin: 1.0,
        ),
        coolantTemp: AlarmThresholds(
          warningMax: 105,
          criticalMax: 115,
        ),
        batteryVoltage: AlarmThresholds(
          warningMin: 11.5,
          warningMax: 14.8,
          criticalMin: 10.5,
          criticalMax: 15.5,
        ),
        current: AlarmThresholds(
          warningMax: 80,
          criticalMax: 100,
        ),
        vacuum: AlarmThresholds(
          warningMax: 90,
          criticalMax: 105,
        ),
        lambdaAfr: AlarmThresholds(
          warningMin: 12.5,
          warningMax: 15.5,
          criticalMin: 10.0,
          criticalMax: 17.0,
        ),
        rpm: AlarmThresholds(
          warningMin: 6500,
          criticalMin: 7000,
        ),
      );

  AlarmConfig copyWith({
    AlarmThresholds? oilPressure,
    AlarmThresholds? coolantTemp,
    AlarmThresholds? batteryVoltage,
    AlarmThresholds? current,
    AlarmThresholds? vacuum,
    AlarmThresholds? lambdaAfr,
    AlarmThresholds? rpm,
  }) {
    return AlarmConfig(
      oilPressure: oilPressure ?? this.oilPressure,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      current: current ?? this.current,
      vacuum: vacuum ?? this.vacuum,
      lambdaAfr: lambdaAfr ?? this.lambdaAfr,
      rpm: rpm ?? this.rpm,
    );
  }

  AlarmState evaluate(MetricType type, double value) {
    switch (type) {
      case MetricType.oilPressure:
        return oilPressure.evaluate(value);
      case MetricType.temperature:
        return coolantTemp.evaluate(value);
      case MetricType.batteryVoltage:
        return batteryVoltage.evaluate(value);
      case MetricType.current:
        return current.evaluate(value);
      case MetricType.vacuum:
        return vacuum.evaluate(value);
      case MetricType.lambda:
        return lambdaAfr.evaluate(value);
      case MetricType.rpm:
        return rpm.evaluate(value);
      default:
        return AlarmState.normal;
    }
  }

  Map<String, dynamic> toMap() => {
        'oilPressure': oilPressure.toMap(),
        'coolantTemp': coolantTemp.toMap(),
        'batteryVoltage': batteryVoltage.toMap(),
        'current': current.toMap(),
        'vacuum': vacuum.toMap(),
        'lambdaAfr': lambdaAfr.toMap(),
        'rpm': rpm.toMap(),
      };

  factory AlarmConfig.fromMap(Map<String, dynamic> map) {
    AlarmThresholds t(String key) {
      final v = map[key];
      return v is Map
          ? AlarmThresholds.fromMap(v.cast<String, dynamic>())
          : const AlarmThresholds();
    }

    return AlarmConfig(
      oilPressure: t('oilPressure'),
      coolantTemp: t('coolantTemp'),
      batteryVoltage: t('batteryVoltage'),
      current: t('current'),
      vacuum: t('vacuum'),
      lambdaAfr: t('lambdaAfr'),
      rpm: t('rpm'),
    );
  }
}