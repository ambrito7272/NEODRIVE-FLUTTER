/// Tipos de métrica do cluster NEODRIVE.
enum MetricType {
  speed,
  rpm,
  fuel,
  temperature,
  oilPressure,
  batteryVoltage,
  current,
  vacuum,
  lambda,
}

/// Estado funcional de um instrumento.
enum AlarmState {
  normal,
  warning,
  critical;
}