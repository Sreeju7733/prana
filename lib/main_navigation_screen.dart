import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/health_hub_screen.dart';
import 'screens/my_card_screen.dart';
import 'screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final int initialSubIndex;
  final bool autoOpenModal;
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.initialSubIndex = 0,
    this.autoOpenModal = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  int _healthSubIndex = 0;
  bool _autoOpenHealthModal = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _healthSubIndex = widget.initialSubIndex;
    _autoOpenHealthModal = widget.autoOpenModal;
  }

  void _onNavigateTab(int index, {int subTabIndex = 0, bool openAddModal = false}) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _healthSubIndex = subTabIndex;
        _autoOpenHealthModal = openAddModal;
      }
    });
    if (openAddModal) {
      Future.microtask(() {
        if (mounted) setState(() => _autoOpenHealthModal = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onNavigateTab),
      HealthHubScreen(
        key: ValueKey('health-hub-$_healthSubIndex-$_autoOpenHealthModal-${DateTime.now().millisecondsSinceEpoch}'),
        initialSubTabIndex: _healthSubIndex,
        autoOpenAdd: _autoOpenHealthModal,
      ),
      const MyCardScreen(),
      const SettingsScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => _onNavigateTab(idx),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_outlined),
              activeIcon: Icon(Icons.badge),
              label: 'My Card',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    ),
  );
  }
}
