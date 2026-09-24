/// Configuração do veículo (escalas e limites físicos).
class VehicleConfig {
  final String engineType;
  final double maxSpeed;
  final double speedMin;
  final double maxRpm;
  final double rpmRedline;
  final double oilMax;
  final double coolantMin;
  final double coolantMax;
  final double batteryMin;
  final double batteryMax;
  final double wheelCircumferenceMeters;

  const VehicleConfig({
    this.engineType = 'VW AP 1.8',
    this.maxSpeed = 220,
    this.speedMin = 0,
    this.maxRpm = 7000,
    this.rpmRedline = 6200,
    this.oilMax = 6,
    this.coolantMin = 40,
    this.coolantMax = 120,
    this.batteryMin = 9,
    this.batteryMax = 16,
    this.wheelCircumferenceMeters = 1.82,
  });

  factory VehicleConfig.defaults() => const VehicleConfig();

  VehicleConfig copyWith({
    String? engineType,
    double? maxSpeed,
    double? speedMin,
    double? maxRpm,
    double? rpmRedline,
    double? oilMax,
    double? coolantMin,
    double? coolantMax,
    double? batteryMin,
    double? batteryMax,
    double? wheelCircumferenceMeters,
  }) {
    return VehicleConfig(
      engineType: engineType ?? this.engineType,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      speedMin: speedMin ?? this.speedMin,
      maxRpm: maxRpm ?? this.maxRpm,
      rpmRedline: rpmRedline ?? this.rpmRedline,
      oilMax: oilMax ?? this.oilMax,
      coolantMin: coolantMin ?? this.coolantMin,
      coolantMax: coolantMax ?? this.coolantMax,
      batteryMin: batteryMin ?? this.batteryMin,
      batteryMax: batteryMax ?? this.batteryMax,
      wheelCircumferenceMeters:
          wheelCircumferenceMeters ?? this.wheelCircumferenceMeters,
    );
  }

  Map<String, dynamic> toMap() => {
        'engineType': engineType,
        'maxSpeed': maxSpeed,
        'speedMin': speedMin,
        'maxRpm': maxRpm,
        'rpmRedline': rpmRedline,
        'oilMax': oilMax,
        'coolantMin': coolantMin,
        'coolantMax': coolantMax,
        'batteryMin': batteryMin,
        'batteryMax': batteryMax,
        'wheelCircumferenceMeters': wheelCircumferenceMeters,
      };

  factory VehicleConfig.fromMap(Map<String, dynamic> map) {
    double g(String key, double fallback) =>
        (map[key] as num?)?.toDouble() ?? fallback;
    return VehicleConfig(
      engineType: (map['engineType'] as String?) ?? 'VW AP 1.8',
      maxSpeed: g('maxSpeed', 220),
      speedMin: g('speedMin', 0),
      maxRpm: g('maxRpm', 7000),
      rpmRedline: g('rpmRedline', 6200),
      oilMax: g('oilMax', 6),
      coolantMin: g('coolantMin', 40),
      coolantMax: g('coolantMax', 120),
      batteryMin: g('batteryMin', 9),
      batteryMax: g('batteryMax', 16),
      wheelCircumferenceMeters: g('wheelCircumferenceMeters', 1.82),
    );
  }
}