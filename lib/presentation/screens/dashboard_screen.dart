import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodrive_1/core/gauge_engine.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';
import 'package:neodrive_1/domain/controllers/dashboard_controller.dart';
import 'package:neodrive_1/widgets/instruments/speedometer.dart';
import 'package:neodrive_1/widgets/instruments/tachometer.dart';
import 'package:neodrive_1/widgets/ui/fuel_bar.dart';
import 'package:neodrive_1/widgets/ui/glass_card.dart';
import 'package:neodrive_1/widgets/ui/neo_background.dart';

/// Tela principal do cluster NEODRIVE.
///
/// Arquitetura visual:
/// - Tachômetro à esquerda (RPM), velocímetro à direita (km/h).
/// - Centro: MFA (leitura digital de velocidade, combustível e cartões de vidro).
/// - Tudo vetorial via `CustomPainter`; nenhuma imagem raster.
class DashboardScreen extends StatelessWidget {
  final DashboardController controller;

  const DashboardScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.backgroundDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: NeoBackground()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Tachometer(
                                  value: controller.rpm,
                                  maxValue: controller.vehicleConfig.maxRpm,
                                  redlineStart:
                                      controller.vehicleConfig.rpmRedline,
                                  alarmState: controller
                                      .getAlarmStateForMetric(MetricType.rpm),
                                ),
                              ),
                            ),
                            Expanded(flex: 5, child: _buildCenterMfa()),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Speedometer(
                                  value: controller.speed,
                                  maxValue: controller.vehicleConfig.maxSpeed,
                                  alarmState: controller.getAlarmStateForMetric(
                                      MetricType.speed),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NEODRIVE',
              style: NeoTheme.digitalFont(
                size: 18.sp,
                color: NeoTheme.neonCyan,
                weight: FontWeight.bold,
              ).copyWith(letterSpacing: 4),
            ),
            Text(
              'PARATI GLS 1.8 AP',
              style: NeoTheme.labelFont(
                size: 9.sp,
                color: NeoTheme.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.01),
              ],
            ),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: NeoTheme.glassBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bluetooth_connected,
                  color: NeoTheme.statusNormal, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'ECU STABLE',
                style: NeoTheme.labelFont(
                  size: 9.sp,
                  color: NeoTheme.statusNormal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CENTRO — MFA (computador de bordo)
  // ───────────────────────────────────────────────────────────────

  Widget _buildCenterMfa() {
    // Box fixo em "design space" escalado por FittedBox — nunca estoura.
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 560.w,
          height: 700.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDigitalSpeed(),
              SizedBox(height: 10.h),
              SizedBox(
                width: 420.w,
                height: 56.h,
                child: FuelBar(
                  level: controller.fuel,
                  max: 50,
                  reserveThreshold: 12,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _glassCard(
                    MetricType.temperature,
                    icon: Icons.thermostat_rounded,
                    unit: '°C',
                    value: controller.temperature.toStringAsFixed(0),
                  ),
                  SizedBox(width: 12.w),
                  _glassCard(
                    MetricType.oilPressure,
                    icon: Icons.water_drop_rounded,
                    unit: 'bar',
                    value: controller.oil.toStringAsFixed(1),
                  ),
                  SizedBox(width: 12.w),
                  _glassCard(
                    MetricType.batteryVoltage,
                    icon: Icons.electric_bolt_rounded,
                    unit: 'V',
                    value: controller.battery.toStringAsFixed(1),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _glassCard(
                    MetricType.vacuum,
                    icon: Icons.air_rounded,
                    unit: 'kPa',
                    value: controller.vacuum.toStringAsFixed(0),
                  ),
                  SizedBox(width: 12.w),
                  _glassCard(
                    MetricType.lambda,
                    icon: Icons.opacity_rounded,
                    unit: 'AFR',
                    value: controller.lambda.toStringAsFixed(1),
                  ),
                  SizedBox(width: 12.w),
                  _glassCard(
                    MetricType.current,
                    icon: Icons.show_chart_rounded,
                    unit: 'A',
                    value: controller.current.toStringAsFixed(0),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildOdometerRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalSpeed() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: controller.speed),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final color = neonArcColorAt(
          (animated / controller.vehicleConfig.maxSpeed).clamp(0.0, 1.0),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              animated.toStringAsFixed(0),
              style: NeoTheme.digitalFont(
                size: 96.sp,
                color: color,
                weight: FontWeight.bold,
              ).copyWith(shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 24),
              ]),
            ),
            SizedBox(width: 8.w),
            Text(
              'km/h',
              style: NeoTheme.unitFont(
                size: 22.sp,
                color: NeoTheme.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glassCard(MetricType type,
      {required IconData icon, required String value, required String unit}) {
    final alarm = controller.getAlarmStateForMetric(type);
    return SizedBox(
      width: 168.w,
      height: 104.h,
      child: GlassCard(
        label: _metricLabel(type),
        value: value,
        unit: unit,
        progress: controller.getValueForMetric(type) /
            controller.getMaxValueForMetric(type),
        alarmState: alarm,
        icon: icon,
      ),
    );
  }

  Widget _buildOdometerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _odometerBox('ODÔMETRO', controller.odometerKm),
        SizedBox(width: 12.w),
        _odometerBox('TRIP', controller.tripKm),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: controller.resetTrip,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: NeoTheme.backgroundCard.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: NeoTheme.glassBorderActive,
                width: 0.5,
              ),
            ),
            child: Icon(Icons.restart_alt_rounded,
                color: NeoTheme.neonCyan, size: 22.sp),
          ),
        ),
      ],
    );
  }

  Widget _odometerBox(String label, double value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NeoTheme.glassBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toStringAsFixed(1),
            style: NeoTheme.digitalFont(
              size: 18.sp,
              color: NeoTheme.textPrimary,
              weight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: NeoTheme.labelFont(size: 7.sp, color: NeoTheme.textDim),
          ),
        ],
      ),
    );
  }

  String _metricLabel(MetricType type) {
    switch (type) {
      case MetricType.temperature:
        return 'TEMP';
      case MetricType.oilPressure:
        return 'ÓLEO';
      case MetricType.batteryVoltage:
        return 'BATERIA';
      case MetricType.vacuum:
        return 'VÁCUO';
      case MetricType.lambda:
        return 'LAMBDA';
      case MetricType.current:
        return 'AMPERES';
      default:
        return '';
    }
  }
}