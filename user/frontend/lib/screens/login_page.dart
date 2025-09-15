import 'package:flutter/material.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  final void Function(User) onLogin;
  final VoidCallback onCreateAccount;
  const LoginPage({super.key, required this.onLogin, required this.onCreateAccount});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController(text: '2000-01-01');

  @override
  void dispose() { name.dispose(); email.dispose(); cpf.dispose(); birth.dispose(); super.dispose(); }

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
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Carteira de Vacinação Digital', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome completo')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(controller: cpf, decoration: const InputDecoration(labelText: 'CPF')),
                TextField(controller: birth, decoration: const InputDecoration(labelText: 'Data de Nascimento (yyyy-MM-dd)')),
                const SizedBox(height: 16),
                FilledButton(onPressed: submit, child: const Text('Entrar')),
                const SizedBox(height: 8),
                TextButton(onPressed: widget.onCreateAccount, child: const Text('Criar conta')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
