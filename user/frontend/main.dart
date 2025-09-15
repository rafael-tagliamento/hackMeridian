// main.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // para hashing simples (mock)
import 'dart:math';

void main() => runApp(const MyApp());

/// ----------------------------
/// MODELOS
/// ----------------------------
class Vaccine {
  final String id;
  final String name;
  final String date; // yyyy-MM-dd
  final String? nextDose; // yyyy-MM-dd
  final String batch;
  final String location;
  final String doctor;
  final String administrationHash; // Código para administrar a vacina
  final String verificationHash;   // Código para comprovar a vacinação

  const Vaccine({
    required this.id,
    required this.name,
    required this.date,
    this.nextDose,
    required this.batch,
    required this.location,
    required this.doctor,
    required this.administrationHash,
    required this.verificationHash,
  });
}

class User {
  final String id;
  final String name;
  final String email;
  final String birthDate; // yyyy-MM-dd
  final String cpf;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.cpf,
  });
}

/// ----------------------------
/// HASH UTILS (mock compatível com sua API)
/// ----------------------------
/// Simula um hash estável a partir de alguns campos.
/// Em produção, troque por sua função real de hash/assinatura.
String generateAdministrationHash({
  required String name,
  required String batch,
  required String location,
  required String doctor,
}) {
  final input = '$name|$batch|$location|$doctor';
  final bytes = utf8.encode(input);
  final base = base64Url.encode(bytes).replaceAll('=', '');
  return 'ADM-${base.substring(0, min(8, base.length)).toUpperCase()}';
}

String generateVerificationHash(
  String administrationHash, {
  required String cpf,
  required String name,
}) {
  final input = '$administrationHash|$cpf|$name';
  final bytes = utf8.encode(input);
  final base = base64Url.encode(bytes).replaceAll('=', '');
  return 'VRF-${base.substring(0, min(8, base.length)).toUpperCase()}';
}

/// ----------------------------
/// APP ROOT
/// ----------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
          fontFamily: 'SF Pro',
        ),
        home: const App(),
      );
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

  void showCreateAccountForm() {
    setState(() => showCreateAccount = true);
  }

  void backToLogin() {
    setState(() => showCreateAccount = false);
  }

  void addVaccine({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
    required String location,
    required String doctor,
  }) {
    final adm = generateAdministrationHash(
      name: name,
      batch: batch,
      location: location,
      doctor: doctor,
    );

    final vrf = (user != null)
        ? generateVerificationHash(adm, cpf: user!.cpf, name: user!.name)
        : '';

    final newVaccine = Vaccine(
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

    setState(() {
      vaccines = [...vaccines, newVaccine];
      // permanece na aba scanner (mesmo comportamento)
    });
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

    Widget child;
    switch (activeTab) {
      case TabType.qrcode:
        child = UserQRCode(user: user!);
        break;
      case TabType.calendar:
        child = VaccinationCalendar(user: user!, vaccines: vaccines);
        break;
      case TabType.scanner:
        child = ScanHealthCenter(
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
      child: child,
    );
  }
}

/// ----------------------------
/// WIDGETS: Login / CreateAccount
/// ----------------------------
class LoginPage extends StatefulWidget {
  final void Function(User) onLogin;
  final VoidCallback onCreateAccount;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final name = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController(text: '2000-01-01');

  @override
  void dispose() {
    email.dispose();
    name.dispose();
    cpf.dispose();
    birth.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.isEmpty || email.text.isEmpty || cpf.text.isEmpty) return;
    widget.onLogin(User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      email: email.text.trim(),
      birthDate: birth.text.trim(),
      cpf: cpf.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                  'Carteira de Vacinação Digital',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome completo')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(controller: cpf, decoration: const InputDecoration(labelText: 'CPF')),
                TextField(controller: birth, decoration: const InputDecoration(labelText: 'Data de Nascimento (yyyy-MM-dd)')),
                const SizedBox(height: 16),
                FilledButton(onPressed: submit, child: const Text('Entrar')),
                const SizedBox(height: 8),
                TextButton(onPressed: widget.onCreateAccount, child: const Text('Criar conta'))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateAccount extends StatefulWidget {
  final void Function(User) onCreateAccount;
  final VoidCallback onBackToLogin;

  const CreateAccount({
    super.key,
    required this.onCreateAccount,
    required this.onBackToLogin,
  });

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final name = TextEditingController();
  final email = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    cpf.dispose();
    birth.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.isEmpty || email.text.isEmpty || cpf.text.isEmpty || birth.text.isEmpty) return;
    widget.onCreateAccount(User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.text.trim(),
      email: email.text.trim(),
      birthDate: birth.text.trim(),
      cpf: cpf.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome completo')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(controller: cpf, decoration: const InputDecoration(labelText: 'CPF')),
                TextField(controller: birth, decoration: const InputDecoration(labelText: 'Data de Nascimento (yyyy-MM-dd)')),
                const SizedBox(height: 16),
                FilledButton(onPressed: submit, child: const Text('Criar e entrar')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------------------
/// TAB NAVIGATION (equivalente ao seu TabNavigation + layout)
/// ----------------------------
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

  int get _currentIndex => activeTab.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user.name.split(' ').first}'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => onTabChange(TabType.values[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code), label: 'QR Code'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.add_a_photo), label: 'Scanner'),
        ],
      ),
    );
  }
}

/// ----------------------------
/// ABA: QR CODE DO USUÁRIO (mock)
/// ----------------------------
class UserQRCode extends StatelessWidget {
  final User user;
  const UserQRCode({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'id': user.id,
      'name': user.name,
      'cpf': user.cpf,
      'email': user.email,
      'birthDate': user.birthDate,
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                  'Identificador do Usuário (para leitura em posto de saúde)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Placeholder de QR: em produção, use um pacote de QR
                SelectableText(
                  payload,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Dica: substitua este card por um QR real (ex.: pacote qr_flutter) contendo o JSON acima.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------------------
/// ABA: CALENDÁRIO / LISTAGEM DE VACINAS
/// ----------------------------
class VaccinationCalendar extends StatelessWidget {
  final User user;
  final List<Vaccine> vaccines;
  const VaccinationCalendar({super.key, required this.user, required this.vaccines});

  Color _statusColor(String? nextDose) {
    if (nextDose == null) return Colors.grey;
    final today = DateTime.now();
    final nd = DateTime.tryParse(nextDose);
    if (nd == null) return Colors.grey;
    if (nd.isBefore(today)) return Colors.red; // atraso
    if (nd.difference(today).inDays <= 10) return Colors.orange; // próximos dias
    return Colors.green; // futuro
    }
  
  String _statusText(String? nextDose) {
    if (nextDose == null) return 'Dose única / sem próxima dose registrada';
    final today = DateTime.now();
    final nd = DateTime.tryParse(nextDose);
    if (nd == null) return 'Próxima dose: data inválida';
    final diff = nd.difference(today).inDays;
    if (diff < 0) return 'Em atraso desde ${nextDose}';
    if (diff == 0) return 'Próxima dose: hoje';
    if (diff <= 10) return 'Próxima dose em $diff dia(s) • $nextDose';
    return 'Próxima dose: $nextDose';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...vaccines]
      ..sort((a, b) {
        final ad = DateTime.tryParse(a.nextDose ?? '') ?? DateTime(2100);
        final bd = DateTime.tryParse(b.nextDose ?? '') ?? DateTime(2100);
        return ad.compareTo(bd);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final v = sorted[i];
        return Card(
          elevation: 1,
          child: ListTile(
            title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aplicada em: ${v.date}'),
                Text('Lote: ${v.batch} • Local: ${v.location} • Profissional: ${v.doctor}'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(v.nextDose).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusText(v.nextDose),
                        style: TextStyle(
                          color: _statusColor(v.nextDose),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Detalhes',
              icon: const Icon(Icons.qr_code_2),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        SelectableText('Admin Code: ${v.administrationHash}'),
                        SelectableText('Verify Code: ${v.verificationHash}'),
                        const SizedBox(height: 8),
                        Text('Local: ${v.location} • Profissional: ${v.doctor}'),
                        Text('Lote: ${v.batch}'),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// ----------------------------
/// ABA: SCANNER (simulação de leitura + cadastro)
/// ----------------------------
class ScanHealthCenter extends StatefulWidget {
  final User user;
  final List<Vaccine> vaccines;
  final void Function({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
    required String location,
    required String doctor,
  }) onAddVaccine;

  const ScanHealthCenter({
    super.key,
    required this.user,
    required this.vaccines,
    required this.onAddVaccine,
  });

  @override
  State<ScanHealthCenter> createState() => _ScanHealthCenterState();
}

class _ScanHealthCenterState extends State<ScanHealthCenter> {
  final name = TextEditingController();
  final date = TextEditingController(text: '2024-12-15');
  final nextDose = TextEditingController();
  final batch = TextEditingController();
  final location = TextEditingController(text: 'UBS Centro');
  final doctor = TextEditingController(text: 'Dr(a). Responsável');

  @override
  void dispose() {
    name.dispose();
    date.dispose();
    nextDose.dispose();
    batch.dispose();
    location.dispose();
    doctor.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.isEmpty || date.text.isEmpty || batch.text.isEmpty || location.text.isEmpty || doctor.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }
    widget.onAddVaccine(
      name: name.text.trim(),
      date: date.text.trim(),
      nextDose: nextDose.text.trim().isEmpty ? null : nextDose.text.trim(),
      batch: batch.text.trim(),
      location: location.text.trim(),
      doctor: doctor.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vacina adicionada com sucesso!')),
    );
    name.clear();
    batch.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Leitura de código do Usuário (simulada)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SelectableText(
                jsonEncode({'cpf': widget.user.cpf, 'name': widget.user.name}),
              ),
              const SizedBox(height: 8),
              const Text('Em produção, substitua por câmera + QR reader.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cadastrar nova vacina', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da vacina *')),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Data de aplicação (yyyy-MM-dd) *')),
              TextField(controller: nextDose, decoration: const InputDecoration(labelText: 'Próxima dose (yyyy-MM-dd)')),
              TextField(controller: batch, decoration: const InputDecoration(labelText: 'Lote *')),
              TextField(controller: location, decoration: const InputDecoration(labelText: 'Local *')),
              TextField(controller: doctor, decoration: const InputDecoration(labelText: 'Profissional *')),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar vacina'),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
