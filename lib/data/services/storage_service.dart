import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calibration_config.dart';
import '../models/vehicle_config.dart';
import '../models/alarm_config.dart';

/// Persistência local (shared_preferences) das configurações do cluster.
class StorageService {
  static const String _keyCalibration = 'neodrive_calibration';
  static const String _keyVehicle = 'neodrive_vehicle_config';
  static const String _keyAlarm = 'neodrive_alarm_config';
  static const String _keyOdometer = 'neodrive_odometer_km';

  Future<void> saveCalibration(CalibrationConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyCalibration, jsonEncode(config.toMap()));
  }

  Future<CalibrationConfig> loadCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCalibration);
    if (raw == null) return CalibrationConfig.defaults();
    try {
      return CalibrationConfig.fromMap(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return CalibrationConfig.defaults();
    }
  }

  Future<void> saveVehicleConfig(VehicleConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVehicle, jsonEncode(config.toMap()));
  }

  Future<VehicleConfig> loadVehicleConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyVehicle);
    if (raw == null) return VehicleConfig.defaults();
    try {
      return VehicleConfig.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return VehicleConfig.defaults();
    }
  }

  Future<void> saveAlarmConfig(AlarmConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAlarm, jsonEncode(config.toMap()));
  }

  Future<AlarmConfig> loadAlarmConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAlarm);
    if (raw == null) return AlarmConfig.defaults();
    try {
      return AlarmConfig.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AlarmConfig.defaults();
    }
  }

  Future<void> saveOdometer(double km) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyOdometer, km);
  }

  Future<double> loadOdometer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyOdometer) ?? 0.0;
  }
}