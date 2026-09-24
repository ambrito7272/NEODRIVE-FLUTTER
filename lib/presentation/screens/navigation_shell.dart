import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neodrive_1/core/neo_theme.dart';
import 'package:neodrive_1/domain/controllers/dashboard_controller.dart';
import 'package:neodrive_1/presentation/screens/dashboard_screen.dart';
import 'package:neodrive_1/presentation/screens/settings_screen.dart';

/// Casca de navegação do NEODRIVE: PAINEL (cluster) e CONFIG (ajustes).
class NavigationShell extends StatefulWidget {
  final DashboardController controller;

  const NavigationShell({super.key, required this.controller});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.backgroundDeep,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: NeoTheme.backgroundCard.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(
              color: NeoTheme.neonCyan.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: NeoTheme.neonCyan,
            unselectedItemColor: NeoTheme.textDim,
            selectedLabelStyle: NeoTheme.labelFont(
                size: 7.sp, color: NeoTheme.neonCyan),
            unselectedLabelStyle: NeoTheme.labelFont(
                size: 7.sp, color: NeoTheme.textDim),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 20),
                label: 'PAINEL',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tune_rounded, size: 20),
                label: 'CONFIG',
              ),
            ],
          ),
        ),
      ),
    );
  }
}