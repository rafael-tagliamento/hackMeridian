import 'package:flutter/material.dart';
import 'startup.dart';

import 'models/user.dart';
import 'models/vaccine.dart';
import 'utils/hash_generator.dart';
import 'utils/user_storage.dart';

// Telas
import 'screens/tab_navigation.dart';
import 'theme/vaccination_calendar.dart';
// --- Use aliases para evitar conflitos ---
import 'screens/user_qrcode.dart' as uq; // ⬅️ MANTENHA SÓ ESTE (com alias)
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

// ✅ Enum unificado com os rótulos usados na navbar
enum TabType { qr, calendario, historico, scanner }

class App extends StatefulWidget {
  final User? initialUser;
  const App({super.key, this.initialUser});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;

  // ✅ Começa na aba de QR
  TabType activeTab = TabType.qr;

  User? user;

  bool _attemptedLazyLoad = false;

  List<Vaccine> vaccines = [
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
    debugPrint('[App] lazyLoadUser: tentando carregar user do storage');
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

  void handleLogout() {
    setState(() {
      user = null;
      isLoggedIn = false;
      activeTab = TabType.qr; // ✅ volta pra primeira aba
    });
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
    setState(() => vaccines = [...vaccines, v]);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn || user == null) {
      debugPrint(
          '[App] build: não logado, user=null, attemptedLazyLoad=$_attemptedLazyLoad');
      if (!_attemptedLazyLoad) {
        _lazyLoadUser();
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      // attemptedLazyLoad == true and still no user -> show actions instead of infinite spinner
      return Scaffold(
        appBar: AppBar(title: const Text('Bem-vindo')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nenhum usuário encontrado.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _attemptedLazyLoad = false;
                    });
                    _lazyLoadUser();
                  },
                  child: const Text('Tentar novamente'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Abre a tela de criação de conta; quando concluída, CreateAccount chamará onCreateAccount
                    final completer = await Navigator.of(context).push<User>(
                      MaterialPageRoute(
                        builder: (routeCtx) => CreateAccount(
                          onCreateAccount: (u) {
                            // passa o usuário de volta via pop no contexto da rota
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
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ escolhe a tela conforme a aba ativa
    Widget body;
    switch (activeTab) {
      case TabType.qr:
        body =
            uq.UserQRCode(user: user!); // usa o UserQRCode da pasta user_qrcode
        break;
      case TabType.calendario:
        body = VaccinationCalendar(user: user!, vaccines: vaccines);
        break;
      case TabType.historico:
        body = HistoricoPage(vaccines: vaccines);
        break;
      case TabType.scanner:
        body = shc.ScanQRCode(
          // scanner genérico que valida assinaturas Stellar
          onDataVerified: (data) {
            // Exemplo: aqui você poderia processar os dados aprovados
            // atualmente apenas mostra uma snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dados aprovados pelo scanner')),
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
