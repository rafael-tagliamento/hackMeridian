import 'package:flutter/material.dart';
import 'startup.dart';

import 'models/user.dart';
import 'models/vaccine.dart';
import 'utils/hash_generator.dart';
import 'utils/user_storage.dart';

// Screens
import 'screens/tab_navigation.dart';
import 'screens/vaccination_calendar.dart';
// --- Use aliases to avoid conflicts ---
import 'screens/user_qrcode.dart' as uq; // ⬅️ KEEP ONLY THIS (with alias)
import 'screens/scan_health_center.dart' as shc;
import 'screens/create_account.dart';

void main() => runApp(const VaccinationApp());

class VaccinationApp extends StatelessWidget {
  const VaccinationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: StartupFlow(),
    );
  }
}

// ✅ Unified enum with the labels used in the navbar
enum TabType { qr, calendar, history, scanner }

class App extends StatefulWidget {
  final User? initialUser;
  const App({super.key, this.initialUser});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;

  // ✅ Starts on the QR tab
  TabType activeTab = TabType.qr;

  User? user;

  bool _attemptedLazyLoad = false;

  List<Vaccine> takenVaccines = [
    Vaccine(
      id: '1',
      name: 'COVID-19 (Pfizer)',
      date: '2024-03-15',
      nextDose: '2024-12-20',
      batch: 'PF001234',
      administrationHash: 'ADM-A1B2C3D4',
      verificationHash: 'VRF-E5F6G7H8',
    ),
    Vaccine(
      id: '2',
      name: 'Flu (Influenza)',
      date: '2024-04-20',
      nextDose: '2025-10-11',
      batch: 'INF5678',
      administrationHash: 'ADM-I9J0K1L2',
      verificationHash: 'VRF-M3N4O5P6',
    ),
    Vaccine(
      id: '3',
      name: 'Hepatitis B',
      date: '2024-02-10',
      nextDose: '2021-02-10',
      batch: 'HEP7890',
      administrationHash: 'ADM-M7N8O9P0',
      verificationHash: 'VRF-Q1R2S3T4',
    ),
    Vaccine(
      id: '4',
      name: 'Tetanus',
      date: '2025-07-07',
      nextDose: '2025-02-15',
      batch: 'TET1122',
      administrationHash: 'ADM-U5V6W7X8',
      verificationHash: 'VRF-Y9Z0A1B2',
    ),
  ];

  List<Vaccine> overdueVaccines = [
    Vaccine(
      id: '2',
      name: 'Flu (Influenza)',
      date: '2021-04-20',
      nextDose: '2024-12-10',
      batch: 'INF5678',
      administrationHash: 'ADM-I9J0K1L2',
      verificationHash: 'VRF-M3N4O5P6',
    ),
    Vaccine(
      id: '3',
      name: 'Hepatitis B',
      date: '2022-02-10',
      nextDose: '2024-12-18',
      batch: 'HEP7890',
      administrationHash: 'ADM-M7N8O9P0',
      verificationHash: 'VRF-Q1R2S3T4',
    ),
  ];

  List<Vaccine> upcomingVaccines = [
    Vaccine(
      id: '1',
      name: 'COVID-19 (Pfizer)',
      date: '2025-03-15',
      nextDose: '2025-09-21',
      batch: 'PF001234',
      administrationHash: 'ADM-A1B2C3D4',
      verificationHash: 'VRF-E5F6G7H8',
    ),
    Vaccine(
      id: '2',
      name: 'Flu (Influenza)',
      date: '2025-09-30',
      nextDose: '2026-10-10',
      batch: 'INF5678',
      administrationHash: 'ADM-I9J0K1L2',
      verificationHash: 'VRF-M3N4O5P6',
    ),
    Vaccine(
      id: '3',
      name: 'Hepatitis B',
      date: '2025-10-15',
      nextDose: '2026-12-18',
      batch: 'HEP7890',
      administrationHash: 'ADM-M7N8O9P0',
      verificationHash: 'VRF-Q1R2S3T4',
    ),
    Vaccine(
      id: '4',
      name: 'Tetanus',
      date: '2025-12-12',
      nextDose: '2026-02-15',
      batch: 'TET1122',
      administrationHash: 'ADM-U5V6W7X8',
      verificationHash: 'VRF-Y9Z0A1B2',
    ),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('[App] initState initialUser=${widget.initialUser != null}');
    if (widget.initialUser != null) {
      user = widget.initialUser;
      isLoggedIn = true;
    }
  }

  Future<void> _lazyLoadUser() async {
    if (_attemptedLazyLoad) return;
    _attemptedLazyLoad = true;
    debugPrint('[App] lazyLoadUser: trying to load user from storage');
    try {
      final us = await UserStorage().load();
      debugPrint('[App] lazyLoadUser: result user=${us != null}');
      if (us != null && mounted) {
        setState(() {
          user = us;
          isLoggedIn = true;
        });
      }
    } catch (e) {
      debugPrint('[App] lazyLoadUser error: $e');
    }
  }

  void handleLogout() async {
    try {
      // optional: clear saved user (adjust if your UserStorage has a different method)
      await UserStorage().clear();
    } catch (_) {}

    // reset any local state (for safety)
    setState(() {
      user = null;
      isLoggedIn = false;
      activeTab = TabType.qr;
    });

    if (!mounted) return;

    // go back to the startup page (StartupFlow) and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StartupFlow()),
          (route) => false,
    );
  }

  void addVaccine({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
  }) {
    final adm = generateAdministrationHash(name: name, batch: batch);
    final vrf = (user != null)
        ? generateVerificationHash(adm, cpf: user!.cpf, name: user!.name)
        : '';

    final v = Vaccine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: date,
      nextDose: nextDose,
      batch: batch,
      administrationHash: adm,
      verificationHash: vrf,
    );
    setState(() => overdueVaccines = [...overdueVaccines, v]);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn || user == null) {
      debugPrint(
          '[App] build: not logged in, user=null, attemptedLazyLoad=$_attemptedLazyLoad');
      if (!_attemptedLazyLoad) {
        _lazyLoadUser();
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      // attemptedLazyLoad == true and still no user -> show actions instead of infinite spinner
      return Scaffold(
        appBar: AppBar(title: const Text('Welcome!')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No user found.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _attemptedLazyLoad = false;
                    });
                    _lazyLoadUser();
                  },
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Opens the account creation screen; when completed, CreateAccount will call onCreateAccount
                    final completer = await Navigator.of(context).push<User>(
                      MaterialPageRoute(
                        builder: (routeCtx) => CreateAccount(
                          onCreateAccount: (u) {
                            // pass the user back via pop in the route context
                            Navigator.of(routeCtx).pop(u);
                          },
                        ),
                      ),
                    );
                    if (completer != null) {
                      setState(() {
                        user = completer;
                        isLoggedIn = true;
                      });
                    }
                  },
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ choose the screen according to the active tab
    Widget body;
    switch (activeTab) {
      case TabType.qr:
        body =
            uq.UserQRCode(user: user!); // use UserQRCode from user_qrcode folder
        break;
      case TabType.calendar:
        body = VaccinationCalendar(
            user: user!,
            vaccinesproximas: upcomingVaccines,
            vaccinesatrasadas: overdueVaccines);
        break;
      case TabType.history:
        body = HistoryPage(vaccinestomadas: takenVaccines);
        break;
      case TabType.scanner:
        body = shc.ScanQRCode(
          // generic scanner that validates Stellar signatures
          onDataVerified: (data) {
            // Example: here you could process the approved data
            // currently it just shows a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data approved by scanner!')),
            );
          },
        );
        break;
    }

    return TabNavigation(
      activeTab: activeTab,
      onTabChange: (t) => setState(() => activeTab = t),
      onLogout: handleLogout,
      user: user!,
      vaccines: takenVaccines,
      child: body,
    );
  }
}

/// Quick placeholder for the History page.
/// Replace with your final screen when ready.
class HistoryPage extends StatelessWidget {
  final List<Vaccine> vaccinestomadas;
  const HistoryPage({super.key, required this.vaccinestomadas});

  @override
  Widget build(BuildContext context) {
    if (vaccinestomadas.isEmpty) {
      return const Center(
        child: Text('No applications recorded.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinestomadas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final v = vaccinestomadas[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(v.name),
          subtitle: Text('Applied on ${v.date} • Batch ${v.batch}'),
        );
      },
    );
  }
}
