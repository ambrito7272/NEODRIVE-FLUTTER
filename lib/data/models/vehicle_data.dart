/// Quadro de telemetria bruto recebido do barramento (ESP32 / simulação).
///
/// Todos os valores são **crus** (unidades físicas) — o `DashboardController`
/// aplica calibração (offset + fator de escala) sobre eles.
class VehicleData {
  final double speed;
  final double rpm;
  final double fuel;
  final double temp;

  final double oil;
  final double battery;
  final double current;
  final double vacuum;
  final double lambda;

  const VehicleData({
    this.speed = 0,
    this.rpm = 0,
    this.fuel = 0,
    this.temp = 0,
    this.oil = 0,
    this.battery = 0,
    this.current = 0,
    this.vacuum = 0,
    this.lambda = 0,
  });
}