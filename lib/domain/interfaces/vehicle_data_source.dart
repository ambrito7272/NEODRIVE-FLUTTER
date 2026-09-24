import '../../data/models/vehicle_data.dart';

abstract class VehicleDataSource {
  Stream<VehicleData> get telemetryStream;
  void dispose();
}
