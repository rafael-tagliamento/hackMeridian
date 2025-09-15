import 'package:flutter/material.dart';
import '../models/user.dart';

class CreateAccount extends StatefulWidget {
  final void Function(User) onCreateAccount;
  final VoidCallback onBackToLogin;
  const CreateAccount({super.key, required this.onCreateAccount, required this.onBackToLogin});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final name = TextEditingController();
  final email = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController();

  @override
  void dispose() { name.dispose(); email.dispose(); cpf.dispose(); birth.dispose(); super.dispose(); }

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
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBackToLogin),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
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
