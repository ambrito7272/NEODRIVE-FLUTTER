import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/data/models/alarm_config.dart';
import 'package:neodrive_1/domain/controllers/dashboard_controller.dart';

/// Tela de configuração — calibração (Fator OEM), alarmes e veículo.
///
/// Usa `ListenableBuilder` (nativo do Flutter) — sem dependência de provider.
class SettingsScreen extends StatelessWidget {
  final DashboardController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: NeoTheme.backgroundCard.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: NeoTheme.neonCyan.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              labelColor: NeoTheme.neonCyan,
              unselectedLabelColor: NeoTheme.textDim,
              indicatorColor: NeoTheme.neonCyan,
              labelStyle: NeoTheme.labelFont(size: 9.sp),
              unselectedLabelStyle:
                  NeoTheme.labelFont(size: 9.sp, color: NeoTheme.textDim),
              tabs: const [
                Tab(text: 'CALIBRAÇÃO'),
                Tab(text: 'ALARMES'),
                Tab(text: 'VEÍCULO'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _CalibrationTab(controller: controller),
                _AlarmTab(controller: controller),
                _VehicleTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CALIBRATION TAB
// ═══════════════════════════════════════════════════════════════

class _CalibrationTab extends StatelessWidget {
  final DashboardController controller;

  const _CalibrationTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final cal = controller.calibration;
        return ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            _sectionTitle('VELOCIDADE (km/h)'),
            _offsetScaleRows(
              cal.speedOffset, cal.speedScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(speedOffset: o, speedScale: s)),
              offsetMin: -30, offsetMax: 30,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('RPM'),
            _offsetScaleRows(
              cal.rpmOffset, cal.rpmScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(rpmOffset: o, rpmScale: s)),
              offsetMin: -1000, offsetMax: 1000,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('ÓLEO (bar)'),
            _offsetScaleRows(
              cal.oilOffset, cal.oilScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(oilOffset: o, oilScale: s)),
              offsetMin: -2, offsetMax: 2,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('TEMPERATURA (°C)'),
            _offsetScaleRows(
              cal.coolantOffset, cal.coolantScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(coolantOffset: o, coolantScale: s)),
              offsetMin: -20, offsetMax: 20,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('BATERIA (V)'),
            _offsetScaleRows(
              cal.batteryOffset, cal.batteryScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(batteryOffset: o, batteryScale: s)),
              offsetMin: -3, offsetMax: 3,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('AMPERES (A)'),
            _offsetScaleRows(
              cal.currentOffset, cal.currentScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(currentOffset: o, currentScale: s)),
              offsetMin: -20, offsetMax: 20,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('VÁCUO (kPa)'),
            _offsetScaleRows(
              cal.vacuumOffset, cal.vacuumScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(vacuumOffset: o, vacuumScale: s)),
              offsetMin: -20, offsetMax: 20,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
            SizedBox(height: 16.h),
            _sectionTitle('LAMBDA (AFR)'),
            _offsetScaleRows(
              cal.lambdaOffset, cal.lambdaScale,
              (o, s) => controller.updateCalibration(
                  cal.copyWith(lambdaOffset: o, lambdaScale: s)),
              offsetMin: -2, offsetMax: 2,
              scaleMin: 0.5, scaleMax: 1.5,
            ),
          ],
        );
      },
    );
  }

  Widget _offsetScaleRows(
    double offset,
    double scale,
    void Function(double o, double s) onUpdate, {
    required double offsetMin,
    required double offsetMax,
    required double scaleMin,
    required double scaleMax,
  }) {
    return Column(
      children: [
        _sliderRow('Offset', offset, offsetMin, offsetMax, (v) {
          onUpdate(v, scale);
        }),
        _sliderRow('Scale', scale, scaleMin, scaleMax, (v) {
          onUpdate(offset, v);
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ALARM TAB
// ═══════════════════════════════════════════════════════════════

class _AlarmTab extends StatelessWidget {
  final DashboardController controller;

  const _AlarmTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final alarm = controller.alarmConfig;
        return ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            _alarmSection('ÓLEO (bar)', alarm.oilPressure, (t) {
              controller.updateAlarmConfig(alarm.copyWith(oilPressure: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('TEMPERATURA (°C)', alarm.coolantTemp, (t) {
              controller.updateAlarmConfig(alarm.copyWith(coolantTemp: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('BATERIA (V)', alarm.batteryVoltage, (t) {
              controller.updateAlarmConfig(alarm.copyWith(batteryVoltage: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('AMPERES (A)', alarm.current, (t) {
              controller.updateAlarmConfig(alarm.copyWith(current: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('VÁCUO (kPa)', alarm.vacuum, (t) {
              controller.updateAlarmConfig(alarm.copyWith(vacuum: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('LAMBDA (AFR)', alarm.lambdaAfr, (t) {
              controller.updateAlarmConfig(alarm.copyWith(lambdaAfr: t));
            }),
            SizedBox(height: 12.h),
            _alarmSection('RPM', alarm.rpm, (t) {
              controller.updateAlarmConfig(alarm.copyWith(rpm: t));
            }),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VEHICLE CONFIG TAB
// ═══════════════════════════════════════════════════════════════

class _VehicleTab extends StatelessWidget {
  final DashboardController controller;

  const _VehicleTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final cfg = controller.vehicleConfig;
        return ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            _sectionTitle('VELOCIDADE (km/h)'),
            _sliderRow('Mín', cfg.speedMin, 0, 50, (v) {
              controller.updateVehicleConfig(cfg.copyWith(speedMin: v));
            }, divisions: 50),
            _sliderRow('Máx', cfg.maxSpeed, 100, 300, (v) {
              controller.updateVehicleConfig(cfg.copyWith(maxSpeed: v));
            }, divisions: 40),
            SizedBox(height: 16.h),
            _sectionTitle('RPM'),
            _sliderRow('Máx', cfg.maxRpm, 4000, 10000, (v) {
              controller.updateVehicleConfig(cfg.copyWith(maxRpm: v));
            }, divisions: 60),
            _sliderRow('Redline', cfg.rpmRedline, 3000, 9000, (v) {
              controller.updateVehicleConfig(cfg.copyWith(rpmRedline: v));
            }, divisions: 60),
            SizedBox(height: 16.h),
            _sectionTitle('ÓLEO (bar)'),
            _sliderRow('Máx', cfg.oilMax, 3, 8, (v) {
              controller.updateVehicleConfig(cfg.copyWith(oilMax: v));
            }, divisions: 50),
            SizedBox(height: 16.h),
            _sectionTitle('TEMPERATURA (°C)'),
            _sliderRow('Mín', cfg.coolantMin, 0, 80, (v) {
              controller.updateVehicleConfig(cfg.copyWith(coolantMin: v));
            }, divisions: 80),
            _sliderRow('Máx', cfg.coolantMax, 80, 150, (v) {
              controller.updateVehicleConfig(cfg.copyWith(coolantMax: v));
            }, divisions: 70),
            SizedBox(height: 16.h),
            _sectionTitle('BATERIA (V)'),
            _sliderRow('Mín', cfg.batteryMin, 6, 12, (v) {
              controller.updateVehicleConfig(cfg.copyWith(batteryMin: v));
            }, divisions: 60),
            _sliderRow('Máx', cfg.batteryMax, 14, 18, (v) {
              controller.updateVehicleConfig(cfg.copyWith(batteryMax: v));
            }, divisions: 40),
            SizedBox(height: 16.h),
            _sectionTitle('RODA'),
            _sliderRow('Circunferência (m)', cfg.wheelCircumferenceMeters,
                1.5, 2.5, (v) {
              controller.updateVehicleConfig(
                  cfg.copyWith(wheelCircumferenceMeters: v));
            }, divisions: 100, decimals: 2),
            SizedBox(height: 8.h),
            _sectionTitle('ODÔMETRO'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.resetOdometer,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text('Zerar odômetro'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeoTheme.statusCritical,
                        side: BorderSide(
                          color: NeoTheme.statusCritical.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.resetTrip,
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Zerar trip'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NeoTheme.neonCyan,
                        side: BorderSide(
                          color: NeoTheme.neonCyan.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

Widget _sectionTitle(String text) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text(
      text,
      style: NeoTheme.labelFont(size: 9.sp, color: NeoTheme.neonCyan),
    ),
  );
}

Widget _sliderRow(
  String label,
  double value,
  double min,
  double max,
  ValueChanged<double> onChanged, {
  int divisions = 100,
  int decimals = 1,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 4.h),
    child: Row(
      children: [
        SizedBox(
          width: 130.w,
          child: Text(
            label,
            style: NeoTheme.labelFont(size: 8.sp, color: NeoTheme.textSecondary),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: NeoTheme.neonCyan,
              inactiveTrackColor: NeoTheme.metalDark,
              thumbColor: NeoTheme.neonCyan,
              overlayColor: NeoTheme.neonCyan.withValues(alpha: 0.1),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 60.w,
          child: Text(
            value.toStringAsFixed(decimals),
            textAlign: TextAlign.right,
            style: NeoTheme.digitalFont(size: 10.sp, color: NeoTheme.textPrimary),
          ),
        ),
      ],
    ),
  );
}

Widget _alarmSection(
  String title,
  AlarmThresholds thresholds,
  ValueChanged<AlarmThresholds> onUpdate,
) {
  final wMin = thresholds.warningMin == double.negativeInfinity
      ? -1000.0
      : thresholds.warningMin;
  final wMax = thresholds.warningMax == double.infinity
      ? 1000.0
      : thresholds.warningMax;
  final cMin = thresholds.criticalMin == double.negativeInfinity
      ? -1000.0
      : thresholds.criticalMin;
  final cMax = thresholds.criticalMax == double.infinity
      ? 1000.0
      : thresholds.criticalMax;

  return Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(
      color: NeoTheme.backgroundCard.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(
        color: NeoTheme.statusWarning.withValues(alpha: 0.15),
        width: 0.5,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: NeoTheme.labelFont(size: 9.sp, color: NeoTheme.statusWarning)),
        SizedBox(height: 6.h),
        Text('WARNING', style: NeoTheme.labelFont(size: 7.sp, color: NeoTheme.statusWarning)),
        _sliderRow('Mín', wMin, -1000, 500, (v) {
          onUpdate(thresholds.copyWith(warningMin: v));
        }, divisions: 150),
        _sliderRow('Máx', wMax, -500, 1000, (v) {
          onUpdate(thresholds.copyWith(warningMax: v));
        }, divisions: 150),
        Text('CRITICAL', style: NeoTheme.labelFont(size: 7.sp, color: NeoTheme.statusCritical)),
        _sliderRow('Mín', cMin, -1000, 500, (v) {
          onUpdate(thresholds.copyWith(criticalMin: v));
        }, divisions: 150),
        _sliderRow('Máx', cMax, -500, 1000, (v) {
          onUpdate(thresholds.copyWith(criticalMax: v));
        }, divisions: 150),
      ],
    ),
  );
}