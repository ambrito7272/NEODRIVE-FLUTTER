import 'dart:async';
import 'dart:math';
import '../models/vehicle_data.dart';
import '../../domain/interfaces/vehicle_data_source.dart';

/// Fonte de dados simulada — permite desenvolver o cluster sem ESP32.
///
/// Emula o comportamento de um VW AP 1.8: aceleração/desaceleração com
/// ruído, rotação subindo e caindo com histerese, e métricas auxiliares
/// (óleo, bateria, vazio, lambda, amperes) variando suavemente.
class SimulationDataSource implements VehicleDataSource {
  final StreamController<VehicleData> _streamController =
      StreamController<VehicleData>.broadcast();
  Timer? _timer;
  final Random _random = Random();

  double _rpm = 900;
  double _speed = 0;
  bool _accelerating = true;

  SimulationDataSource({bool autoStart = true}) {
    if (autoStart) _start();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _tick();
    });
  }

  void _tick() {
    if (_accelerating) {
      _rpm += _random.nextDouble() * 120 + 30;
      _speed += _random.nextDouble() * 1.5;
      if (_rpm >= 6200) _accelerating = false;
    } else {
      _rpm -= _random.nextDouble() * 200 + 50;
      _speed -= _random.nextDouble() * 0.8;
      if (_rpm <= 1100) _accelerating = true;
    }

    _speed = _speed.clamp(0, 220);
    _rpm = _rpm.clamp(850, 7000);

    if (_streamController.isClosed) return;

    _streamController.add(VehicleData(
      speed: _speed,
      rpm: _rpm,
      fuel: 42.5 + (sin(DateTime.now().millisecondsSinceEpoch / 5000) * 0.5),
      temp: 89.0 + (_rpm > 5000 ? 2.0 : 0.0),
      oil: 3.2 + (cos(DateTime.now().millisecondsSinceEpoch / 8000) * 0.15),
      battery: 14.1 + (sin(DateTime.now().millisecondsSinceEpoch / 6000) * 0.2),
      current: 40.0 + (_rpm / 7000) * 25 + _random.nextDouble() * 5,
      vacuum: 55.0 + (1 - (_rpm - 850) / 6150) * 25 + _random.nextDouble() * 3,
      lambda: 14.7 + sin(DateTime.now().millisecondsSinceEpoch / 3000) * 0.4,
    ));
  }

  @override
  Stream<VehicleData> get telemetryStream => _streamController.stream;

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (!_streamController.isClosed) _streamController.close();
  }
}