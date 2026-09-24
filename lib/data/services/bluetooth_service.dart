import 'dart:async';
import '../models/vehicle_data.dart';
import '../../domain/interfaces/vehicle_data_source.dart';

/// Serviço de integração Bluetooth (ESP32) — esqueleto OEM.
///
/// Recebe pacotes CSV via Serial e os traduz em `VehicleData`:
/// `SPD:145,RPM:3200,FUEL:42,TEMP:89,OIL:3.2,BAT:14.1,CUR:45,VAC:58,LAM:14.7`
///
/// O canal físico (peripheral discovery, UUID de serviço, bytes) deve ser
/// implementado na integração real com `flutter_blue_plus` ou `bluetooth_serial`.
class BluetoothService implements VehicleDataSource {
  final StreamController<VehicleData> _streamController =
      StreamController<VehicleData>.broadcast();

  bool _listening = false;

  /// Conecta e começa a escutar o serial Bluetooth.
  Future<void> startListening() async {
    _listening = true;
    // TODO(ESP32): descobrir dispositivo, conectar, escutar bytes e
    // invocar [parseRawPacket] para cada linha recebida.
  }

  Future<void> stopListening() async {
    _listening = false;
  }

  bool get isListening => _listening;

  /// Traduz uma linha CSV `CHAVE:VALOR,CHAVE:VALOR` em telemetria.
  void parseRawPacket(String packet) {
    if (_streamController.isClosed) return;
    try {
      final parts = packet.split(',');
      double speed = 0;
      double rpm = 0;
      double fuel = 0;
      double temp = 0;
      double oil = 0;
      double battery = 0;
      double current = 0;
      double vacuum = 0;
      double lambda = 0;

      for (final part in parts) {
        final pair = part.split(':');
        if (pair.length != 2) continue;
        final key = pair[0].trim().toUpperCase();
        final val = double.tryParse(pair[1].trim()) ?? 0;

        switch (key) {
          case 'SPD':
            speed = val;
          case 'RPM':
            rpm = val;
          case 'FUEL':
            fuel = val;
          case 'TEMP':
            temp = val;
          case 'OIL':
            oil = val;
          case 'BAT':
          case 'BATT':
            battery = val;
          case 'CUR':
          case 'AMPS':
            current = val;
          case 'VAC':
            vacuum = val;
          case 'LAM':
          case 'AFR':
            lambda = val;
        }
      }

      _streamController.add(VehicleData(
        speed: speed,
        rpm: rpm,
        fuel: fuel,
        temp: temp,
        oil: oil,
        battery: battery,
        current: current,
        vacuum: vacuum,
        lambda: lambda,
      ));
    } catch (_) {
      // Pacote malformado — ignorar silenciosamente.
    }
  }

  @override
  Stream<VehicleData> get telemetryStream => _streamController.stream;

  @override
  void dispose() {
    if (!_streamController.isClosed) _streamController.close();
  }
}