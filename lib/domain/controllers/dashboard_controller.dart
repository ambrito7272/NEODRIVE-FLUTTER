import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/vehicle_data.dart';
import '../../data/models/vehicle_config.dart';
import '../../data/models/alarm_config.dart';
import '../../data/models/calibration_config.dart';
import '../../data/models/alarm_state.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/simulation_data_source.dart';
import '../interfaces/vehicle_data_source.dart';

/// Controller único do cluster NEODRIVE.
///
/// Responsabilidades:
/// 1. Assinar a fonte de dados (simulação ou Bluetooth).
/// 2. Aplicar calibração (offset + escala) aos valores crus.
/// 3. Acumular odômetro/trip a partir da velocidade.
/// 4. Avaliar alarmes (warning/critical) por métrica.
/// 5. Persistir calibração, alarmes, config do veículo e odômetro.
class DashboardController extends ChangeNotifier {
  final VehicleDataSource _dataSource;
  final StorageService _storageService;
  StreamSubscription<VehicleData>? _telemetrySubscription;

  // ── Métricas calibradas (exibição) ──
  double speed = 0.0;
  double rpm = 0.0;
  double fuel = 0.0;
  double temperature = 0.0;
  double oil = 0.0;
  double battery = 0.0;
  double current = 0.0;
  double vacuum = 0.0;
  double lambda = 0.0;

  // ── Odômetro / trip ──
  double odometerKm = 0.0;
  double tripKm = 0.0;
  DateTime? _lastFrame;
  bool _odometerReady = false;

  // ── Configurações persistidas ──
  CalibrationConfig calibration = CalibrationConfig.defaults();
  VehicleConfig vehicleConfig = VehicleConfig.defaults();
  AlarmConfig alarmConfig = AlarmConfig.defaults();

  DashboardController({
    required VehicleDataSource dataSource,
    required StorageService storageService,
  })  : _dataSource = dataSource,
        _storageService = storageService;

  Future<void> init() async {
    calibration = await _storageService.loadCalibration();
    vehicleConfig = await _storageService.loadVehicleConfig();
    alarmConfig = await _storageService.loadAlarmConfig();
    odometerKm = await _storageService.loadOdometer();

    _telemetrySubscription = _dataSource.telemetryStream.listen((data) {
      _applyFrame(data);
    });
    notifyListeners();
  }

  void _applyFrame(VehicleData d) {
    speed = calibration.calibrateSpeed(d.speed).clamp(0, vehicleConfig.maxSpeed);
    rpm = calibration.calibrateRpm(d.rpm).clamp(0, vehicleConfig.maxRpm);
    fuel = d.fuel.clamp(0, 50);
    temperature = calibration.calibrateCoolant(d.temp);
    oil = calibration.calibrateOil(d.oil);
    battery = calibration.calibrateBattery(d.battery);
    current = calibration.calibrateCurrent(d.current);
    vacuum = calibration.calibrateVacuum(d.vacuum);
    lambda = calibration.calibrateLambda(d.lambda);

    _accumulateOdometer(d.speed);

    if (hasListeners) notifyListeners();
  }

  void _accumulateOdometer(double rawSpeedKmh) {
    final now = DateTime.now();
    if (_lastFrame != null) {
      final dtHours = now.difference(_lastFrame!).inMilliseconds /
          Duration.millisecondsPerHour;
      if (dtHours > 0 && dtHours < 1) {
        final deltaKm = rawSpeedKmh * dtHours;
        odometerKm += deltaKm;
        tripKm += deltaKm;
        _odometerReady = true;
      }
    }
    _lastFrame = now;
  }

  // ───────────────────────────────────────────────────────────────
  // Calibração
  // ───────────────────────────────────────────────────────────────

  Future<void> updateCalibration(CalibrationConfig next) async {
    calibration = next;
    await _storageService.saveCalibration(next);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────
  // Alarmes
  // ───────────────────────────────────────────────────────────────

  Future<void> updateAlarmConfig(AlarmConfig next) async {
    alarmConfig = next;
    await _storageService.saveAlarmConfig(next);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────
  // Veículo
  // ───────────────────────────────────────────────────────────────

  Future<void> updateVehicleConfig(VehicleConfig next) async {
    vehicleConfig = next;
    await _storageService.saveVehicleConfig(next);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────
  // Odômetro
  // ───────────────────────────────────────────────────────────────

  void resetTrip() {
    tripKm = 0;
    notifyListeners();
  }

  Future<void> resetOdometer() async {
    odometerKm = 0;
    await _storageService.saveOdometer(0);
    notifyListeners();
  }

  Future<void> _persistOdometer() async {
    if (_odometerReady) await _storageService.saveOdometer(odometerKm);
  }

  // ───────────────────────────────────────────────────────────────
  // Consumidores
  // ───────────────────────────────────────────────────────────────

  bool get isSimulation => _dataSource is SimulationDataSource;

  double getMaxValueForMetric(MetricType type) {
    switch (type) {
      case MetricType.speed:
        return vehicleConfig.maxSpeed;
      case MetricType.rpm:
        return vehicleConfig.maxRpm;
      case MetricType.fuel:
        return 50.0;
      case MetricType.temperature:
        return vehicleConfig.coolantMax;
      case MetricType.oilPressure:
        return vehicleConfig.oilMax;
      case MetricType.batteryVoltage:
        return vehicleConfig.batteryMax;
      case MetricType.current:
        return 120.0;
      case MetricType.vacuum:
        return 100.0;
      case MetricType.lambda:
        return 20.0;
    }
  }

  double getValueForMetric(MetricType type) {
    switch (type) {
      case MetricType.speed:
        return speed;
      case MetricType.rpm:
        return rpm;
      case MetricType.fuel:
        return fuel;
      case MetricType.temperature:
        return temperature;
      case MetricType.oilPressure:
        return oil;
      case MetricType.batteryVoltage:
        return battery;
      case MetricType.current:
        return current;
      case MetricType.vacuum:
        return vacuum;
      case MetricType.lambda:
        return lambda;
    }
  }

  AlarmState getAlarmStateForMetric(MetricType type) {
    return alarmConfig.evaluate(type, getValueForMetric(type));
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _lastFrame = null;
    _persistOdometer();
    super.dispose();
  }
}