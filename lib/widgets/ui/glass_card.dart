import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/data/models/alarm_state.dart';

/// Cartão de vidro NEODRIVE — glassmorphism automotivo premium.
///
/// Diretriz 1: `LinearGradient` com transparência (corpo a ~0.8 de opacidade)
/// + borda de **0.5px** branca a **0.05** de opacidade.
///
/// Diretriz 5: a barra de progresso é **sempre** envolvida por `Expanded`
/// dentro de uma `Row` — impossível ocorrer `BoxConstraints forces an infinite
/// width`.
///
/// Diretriz 6: apenas `.w`, `.h`, `.sp` via `flutter_screenutil`.
class GlassCard extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final double progress;
  final AlarmState alarmState;
  final IconData icon;

  const GlassCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.progress,
    required this.alarmState,
    required this.icon,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    if (widget.alarmState == AlarmState.critical) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alarmState == AlarmState.critical) {
      if (!_blink.isAnimating) _blink.repeat(reverse: true);
    } else {
      _blink
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.alarmState) {
      case AlarmState.normal:
        return NeoTheme.neonCyan;
      case AlarmState.warning:
        return NeoTheme.statusWarning;
      case AlarmState.critical:
        return NeoTheme.statusCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blink,
      builder: (context, _) {
        final opacity =
            widget.alarmState == AlarmState.critical ? _blink.value : 1.0;
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              // Diretriz 1 — corpo de vidro a ~0.8 de opacidade
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NeoTheme.backgroundCard.withValues(alpha: 0.8),
                  NeoTheme.backgroundElevated.withValues(alpha: 0.8),
                  NeoTheme.backgroundCard.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              // Diretriz 1 — borda 0.5px branca a 0.05 de opacidade
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.07),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
                const BoxShadow(
                  color: NeoTheme.shadowDeep,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: const _GlassHighlightPainter(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, size: 14.w, color: _accent),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.label.toUpperCase(),
                          style: NeoTheme.labelFont(
                            size: 8.sp,
                            color: NeoTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          widget.value,
                          style: NeoTheme.digitalFont(
                            size: 20.sp,
                            color: _accent,
                            weight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          widget.unit,
                          style: NeoTheme.unitFont(
                            size: 9.sp,
                            color: NeoTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildProgressBar(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final p = widget.progress.clamp(0.0, 1.0);
    // Diretriz 5 — barra SEMPRE dentro de Row + Expanded
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              color: NeoTheme.backgroundDeep.withValues(alpha: 0.7),
            ),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: p,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.r),
                    gradient: LinearGradient(
                      colors: [
                        _accent.withValues(alpha: 0.65),
                        _accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassHighlightPainter extends CustomPainter {
  const _GlassHighlightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.4);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [NeoTheme.glassHighlight, Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
