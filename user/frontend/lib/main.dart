import 'package:flutter/material.dart';

// IMPORTA O SEU TEMA NOVO
import 'theme/theme.dart'; // <- ajuste o caminho se estiver em outra pasta (ex.: 'theme/theme.dart')

import 'models/user.dart';
import 'models/vaccine.dart';
import 'utils/hash_generator.dart';
import 'screens/login_page.dart';
import 'screens/create_account.dart';
import 'screens/tab_navigation.dart';
import 'screens/user_qrcode.dart';
import 'screens/vaccination_calendar.dart';
import 'screens/scan_health_center.dart';

void main() => runApp(const VaccinationApp());

class VaccinationApp extends StatelessWidget {
  const VaccinationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ⬇️ APLICA O TEMA DO ARQUIVO theme.dart
      theme: ThemeData.light(),          // tema claro
      darkTheme: ThemeData.dark(),       // tema escuro (se existir)
      themeMode: ThemeMode.system,    // alterna conforme o sistema (pode trocar para ThemeMode.light/dark)

      home: const App(),
    );
  }
}

enum TabType { qrcode, calendar, scanner }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;
  bool showCreateAccount = false;
  TabType activeTab = TabType.qrcode;
  User? user;

  List<Vaccine> vaccines = [
    Vaccine(
      id: '1',
      name: 'COVID-19 (Pfizer)',
      date: '2024-03-15',
      nextDose: '2024-12-20',
      batch: 'PF001234',
      location: 'UBS Centro',
      doctor: 'Dr. Maria Silva',
      administrationHash: 'ADM-A1B2C3D4',
      verificationHash: 'VRF-E5F6G7H8',
    ),
    Vaccine(
      id: '2',
      name: 'Gripe (Influenza)',
      date: '2024-04-20',
      nextDose: '2024-12-10',
      batch: 'INF5678',
      location: 'Clínica Santa Cruz',
      doctor: 'Dr. João Santos',
      administrationHash: 'ADM-I9J0K1L2',
      verificationHash: 'VRF-M3N4O5P6',
    ),
    Vaccine(
      id: '3',
      name: 'Hepatite B',
      date: '2024-02-10',
      nextDose: '2024-12-18',
      batch: 'HEP7890',
      location: 'Hospital São José',
      doctor: 'Dr. Ana Costa',
      administrationHash: 'ADM-M7N8O9P0',
      verificationHash: 'VRF-Q1R2S3T4',
    ),
    Vaccine(
      id: '4',
      name: 'Tétano',
      date: '2024-01-05',
      nextDose: '2025-02-15',
      batch: 'TET1122',
      location: 'UBS Norte',
      doctor: 'Dr. Pedro Lima',
      administrationHash: 'ADM-U5V6W7X8',
      verificationHash: 'VRF-Y9Z0A1B2',
    ),
  ];

  void handleLogin(User userData) {
    setState(() {
      user = userData;
      isLoggedIn = true;
    });
  }

  void handleCreateAccount(User userData) {
    setState(() {
      user = userData;
      isLoggedIn = true;
      showCreateAccount = false;
    });
  }

  void handleLogout() {
    setState(() {
      user = null;
      isLoggedIn = false;
      showCreateAccount = false;
      activeTab = TabType.qrcode;
    });
  }

  void showCreateAccountForm() => setState(() => showCreateAccount = true);
  void backToLogin() => setState(() => showCreateAccount = false);

  void addVaccine({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
    required String location,
    required String doctor,
  }) {
    final adm = generateAdministrationHash(
      name: name, batch: batch, location: location, doctor: doctor,
    );
    final vrf = (user != null)
        ? 'VRF-${generateHash('$adm-${user!.cpf}-${user!.name}')}'
        : '';

    final v = Vaccine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: date,
      nextDose: nextDose,
      batch: batch,
      location: location,
      doctor: doctor,
      administrationHash: adm,
      verificationHash: vrf,
    );
    setState(() => vaccines = [...vaccines, v]);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn || user == null) {
      if (showCreateAccount) {
        return CreateAccount(
          onCreateAccount: handleCreateAccount,
          onBackToLogin: backToLogin,
        );
      }
      return LoginPage(
        onLogin: handleLogin,
        onCreateAccount: showCreateAccountForm,
      );
    }

    Widget body;
    switch (activeTab) {
      case TabType.qrcode:
        body = UserQRCode(user: user!);
        break;
      case TabType.calendar:
        body = VaccinationCalendar(user: user!, vaccines: vaccines);
        break;
      case TabType.scanner:
        body = ScanHealthCenter(
          user: user!, vaccines: vaccines, onAddVaccine: addVaccine,
        );
        break;
    }

    return TabNavigation(
      activeTab: activeTab,
      onTabChange: (t) => setState(() => activeTab = t),
      onLogout: handleLogout,
      user: user!,
      vaccines: vaccines,
      child: body,
    );
  }
}