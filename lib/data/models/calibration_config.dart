/// Configuração de calibração do barramento (Fator OEM).
///
/// Para cada métrica há um par `offset + scale`, onde o valor exibido é:
/// `valorExibido = (valorBruto * scale) + offset`.
///
/// Persistida via `StorageService` como JSON (shared_preferences).
class CalibrationConfig {
  final double speedOffset;
  final double speedScale;
  final double rpmOffset;
  final double rpmScale;
  final double oilOffset;
  final double oilScale;
  final double coolantOffset;
  final double coolantScale;
  final double batteryOffset;
  final double batteryScale;
  final double currentOffset;
  final double currentScale;
  final double vacuumOffset;
  final double vacuumScale;
  final double lambdaOffset;
  final double lambdaScale;

  const CalibrationConfig({
    this.speedOffset = 0,
    this.speedScale = 1,
    this.rpmOffset = 0,
    this.rpmScale = 1,
    this.oilOffset = 0,
    this.oilScale = 1,
    this.coolantOffset = 0,
    this.coolantScale = 1,
    this.batteryOffset = 0,
    this.batteryScale = 1,
    this.currentOffset = 0,
    this.currentScale = 1,
    this.vacuumOffset = 0,
    this.vacuumScale = 1,
    this.lambdaOffset = 0,
    this.lambdaScale = 1,
  });

  factory CalibrationConfig.defaults() => const CalibrationConfig();

  double apply(double raw, double offset, double scale) => (raw * scale) + offset;

  double calibrateSpeed(double raw) => apply(raw, speedOffset, speedScale);
  double calibrateRpm(double raw) => apply(raw, rpmOffset, rpmScale);
  double calibrateOil(double raw) => apply(raw, oilOffset, oilScale);
  double calibrateCoolant(double raw) => apply(raw, coolantOffset, coolantScale);
  double calibrateBattery(double raw) => apply(raw, batteryOffset, batteryScale);
  double calibrateCurrent(double raw) => apply(raw, currentOffset, currentScale);
  double calibrateVacuum(double raw) => apply(raw, vacuumOffset, vacuumScale);
  double calibrateLambda(double raw) => apply(raw, lambdaOffset, lambdaScale);

  CalibrationConfig copyWith({
    double? speedOffset,
    double? speedScale,
    double? rpmOffset,
    double? rpmScale,
    double? oilOffset,
    double? oilScale,
    double? coolantOffset,
    double? coolantScale,
    double? batteryOffset,
    double? batteryScale,
    double? currentOffset,
    double? currentScale,
    double? vacuumOffset,
    double? vacuumScale,
    double? lambdaOffset,
    double? lambdaScale,
  }) {
    return CalibrationConfig(
      speedOffset: speedOffset ?? this.speedOffset,
      speedScale: speedScale ?? this.speedScale,
      rpmOffset: rpmOffset ?? this.rpmOffset,
      rpmScale: rpmScale ?? this.rpmScale,
      oilOffset: oilOffset ?? this.oilOffset,
      oilScale: oilScale ?? this.oilScale,
      coolantOffset: coolantOffset ?? this.coolantOffset,
      coolantScale: coolantScale ?? this.coolantScale,
      batteryOffset: batteryOffset ?? this.batteryOffset,
      batteryScale: batteryScale ?? this.batteryScale,
      currentOffset: currentOffset ?? this.currentOffset,
      currentScale: currentScale ?? this.currentScale,
      vacuumOffset: vacuumOffset ?? this.vacuumOffset,
      vacuumScale: vacuumScale ?? this.vacuumScale,
      lambdaOffset: lambdaOffset ?? this.lambdaOffset,
      lambdaScale: lambdaScale ?? this.lambdaScale,
    );
  }

  Map<String, double> toMap() => {
        'speedOffset': speedOffset,
        'speedScale': speedScale,
        'rpmOffset': rpmOffset,
        'rpmScale': rpmScale,
        'oilOffset': oilOffset,
        'oilScale': oilScale,
        'coolantOffset': coolantOffset,
        'coolantScale': coolantScale,
        'batteryOffset': batteryOffset,
        'batteryScale': batteryScale,
        'currentOffset': currentOffset,
        'currentScale': currentScale,
        'vacuumOffset': vacuumOffset,
        'vacuumScale': vacuumScale,
        'lambdaOffset': lambdaOffset,
        'lambdaScale': lambdaScale,
      };

  factory CalibrationConfig.fromMap(Map<String, dynamic> map) {
    double g(String key, double fallback) =>
        (map[key] as num?)?.toDouble() ?? fallback;
    return CalibrationConfig(
      speedOffset: g('speedOffset', 0),
      speedScale: g('speedScale', 1),
      rpmOffset: g('rpmOffset', 0),
      rpmScale: g('rpmScale', 1),
      oilOffset: g('oilOffset', 0),
      oilScale: g('oilScale', 1),
      coolantOffset: g('coolantOffset', 0),
      coolantScale: g('coolantScale', 1),
      batteryOffset: g('batteryOffset', 0),
      batteryScale: g('batteryScale', 1),
      currentOffset: g('currentOffset', 0),
      currentScale: g('currentScale', 1),
      vacuumOffset: g('vacuumOffset', 0),
      vacuumScale: g('vacuumScale', 1),
      lambdaOffset: g('lambdaOffset', 0),
      lambdaScale: g('lambdaScale', 1),
    );
  }
}