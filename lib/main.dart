import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'data/services/storage_service.dart';
import 'data/services/simulation_data_source.dart';
import 'domain/controllers/dashboard_controller.dart';
import 'presentation/screens/navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final simulationDataSource = SimulationDataSource();
  final storageService = StorageService();

  final dashboardController = DashboardController(
    dataSource: simulationDataSource,
    storageService: storageService,
  );
  await dashboardController.init();

  runApp(NeoDriveApp(controller: dashboardController));
}

class NeoDriveApp extends StatelessWidget {
  final DashboardController controller;

  const NeoDriveApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp(
          title: 'NEODRIVE CLUSTER',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF05070B),
            fontFamily: 'Orbitron',
            fontFamilyFallback: const ['Courier New'],
          ),
          home: NavigationShell(controller: controller),
        );
      },
    );
  }
}