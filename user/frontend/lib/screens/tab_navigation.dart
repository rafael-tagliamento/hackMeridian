import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vaccine.dart';
import '../main.dart';

class TabNavigation extends StatelessWidget {
  final TabType activeTab;
  final void Function(TabType) onTabChange;
  final VoidCallback onLogout;
  final User user;
  final List<Vaccine> vaccines;
  final Widget child;

  const TabNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChange,
    required this.onLogout,
    required this.user,
    required this.vaccines,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${user.name.split(' ').first}!'),
        actions: [
          IconButton(
            onPressed: onLogout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeTab.index,
        onDestinationSelected: (i) => onTabChange(TabType.values[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code), label: 'QR Code'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'), // 👈 new tab
          NavigationDestination(icon: Icon(Icons.add_a_photo), label: 'Scanner'),
        ],
      ),
    );
  }
}
