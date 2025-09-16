import 'package:flutter/material.dart';

// IMPORTA O SEU TEMA NOVO (opcional – use se já tiver configurado)
import 'theme/theme.dart';

import 'models/user.dart';
import 'models/vaccine.dart';
import 'utils/hash_generator.dart';

// Telas
import 'screens/login_page.dart';
import 'screens/create_account.dart';
import 'screens/tab_navigation.dart';
import 'screens/vaccination_calendar.dart';  // ⬅️ ADICIONE ESTE
// --- Use aliases para evitar conflitos ---
import 'screens/user_qrcode.dart' as uq;      // ⬅️ MANTENHA SÓ ESTE (com alias)
import 'screens/scan_health_center.dart' as shc;

void main() => runApp(const VaccinationApp());

class VaccinationApp extends StatelessWidget {
  const VaccinationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ⬇️ aplique seu tema aqui, se tiver
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,

      home: const App(),
    );
  }
}

// ✅ Enum unificado com os rótulos usados na navbar
enum TabType { qr, calendario, historico, scanner }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;
  bool showCreateAccount = false;

  TabType activeTab = TabType.qr;

  User? user;

  List<Vaccine> vaccines = [
    Vaccine(
      id: '1',
      name: 'COVID-19 (Pfizer)',
      date: '2024-03-15',
      nextDose: '2025-12-20',
      batch: 'PF001234',
      administrationHash: 'ADM-A1B2C3D4',
      verificationHash: 'VRF-E5F6G7H8',
    ),
    Vaccine(
      id: '2',
      name: 'Gripe (Influenza)',
      date: '2024-04-20',
      nextDose: '2024-12-10',
      batch: 'INF5678',
      administrationHash: 'ADM-I9J0K1L2',
      verificationHash: 'VRF-M3N4O5P6',
    ),
    Vaccine(
      id: '3',
      name: 'Hepatite B',
      date: '2024-02-10',
      nextDose: '2024-12-18',
      batch: 'HEP7890',
      administrationHash: 'ADM-M7N8O9P0',
      verificationHash: 'VRF-Q1R2S3T4',
    ),
    Vaccine(
      id: '4',
      name: 'Tétano',
      date: '2024-01-05',
      nextDose: '2025-02-15',
      batch: 'TET1122',
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
      activeTab = TabType.qr; // ✅ volta pra primeira aba
    });
  }

  void showCreateAccountForm() => setState(() => showCreateAccount = true);
  void backToLogin() => setState(() => showCreateAccount = false);

  void addVaccine({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
  }) {
    final adm = generateAdministrationHash(
      name: name, batch: batch,
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

    // ✅ escolhe a tela conforme a aba ativa
    Widget body;
    switch (activeTab) {
      case TabType.qr:
        body = uq.UserQRCode(user: user!);   // usa o UserQRCode da pasta user_qrcode
        break;
      case TabType.calendario:
        body = VaccinationCalendar(user: user!, vaccines: vaccines);
        break;
      case TabType.historico:
        body = HistoricoPage(vaccines: vaccines);
        break;
      case TabType.scanner:
        body = shc.ScanHealthCenter(        // usa o ScanHealthCenter da pasta scan_health_center
          user: user!,
          vaccines: vaccines,
          onAddVaccine: addVaccine,
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

/// Placeholder rápido da página de Histórico.
/// Troque por sua tela final quando quiser.
class HistoricoPage extends StatelessWidget {
  final List<Vaccine> vaccines;
  const HistoricoPage({super.key, required this.vaccines});

  @override
  Widget build(BuildContext context) {
    if (vaccines.isEmpty) {
      return const Center(
        child: Text('Sem aplicações registradas.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vaccines.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final v = vaccines[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(v.name),
          subtitle: Text('Aplicada em ${v.date} • Lote ${v.batch}'),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}
