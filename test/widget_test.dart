import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neodrive_1/main.dart';
import 'package:neodrive_1/data/services/storage_service.dart';
import 'package:neodrive_1/data/services/simulation_data_source.dart';
import 'package:neodrive_1/domain/controllers/dashboard_controller.dart';
import 'package:neodrive_1/widgets/ui/fuel_bar.dart';

void main() {
  testWidgets('NEODRIVE dashboard renders without errors',
      (WidgetTester tester) async {
    // Sem busca de fonte em runtime dentro do teste (determinístico).
    GoogleFonts.config.allowRuntimeFetching = false;

    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    final dataSource = SimulationDataSource(autoStart: false);
    final controller = DashboardController(
      dataSource: dataSource,
      storageService: storage,
    );
    await controller.init();

    await tester.pumpWidget(NeoDriveApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('NEODRIVE'), findsOneWidget);
    expect(find.text('PARATI GLS 1.8 AP'), findsOneWidget);
    expect(find.text('PAINEL'), findsOneWidget);
    expect(find.text('CONFIG'), findsOneWidget);

    // FuelBar linear presente no centro do cluster.
    expect(find.byType(FuelBar), findsOneWidget);

    controller.dispose();
    dataSource.dispose();
  });
}