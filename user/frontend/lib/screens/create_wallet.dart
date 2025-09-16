import 'package:flutter/material.dart';
import '../utils/security_service.dart';
import '../utils/stellar.dart';

class CreateWalletScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onCreated;
  const CreateWalletScreen(
      {super.key, required this.securityService, required this.onCreated});
  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _pinController = TextEditingController();
  final _pin2Controller = TextEditingController();
  String? _error;
  bool _loading = false;
  String? _generatedSeed; // mostrar para backup

  Future<void> _create() async {
    final p1 = _pinController.text.trim();
    final p2 = _pin2Controller.text.trim();
    if (p1.length < 4) {
      setState(() => _error = 'PIN mínimo 4 dígitos');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'PINs não coincidem');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    // cria chave
    final kp = await widget.securityService.keyManager.loadOrCreate();
    await widget.securityService.setPin(p1);
    final stellar =
        StellarService.forTestNet(widget.securityService.keyManager);
    await stellar.friendBotIfNeeded();
    _generatedSeed = kp.secretSeed; // seed para exibir uma única vez
    if (mounted) setState(() {});
  }

  void _confirmSaved() {
    widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Carteira Stellar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_generatedSeed == null) ...[
            const Text('Defina um PIN que protegerá sua carteira.'),
            const SizedBox(height: 12),
            TextField(
                obscureText: true,
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration:
                    const InputDecoration(labelText: 'PIN (4-6 dígitos)')),
            TextField(
                obscureText: true,
                controller: _pin2Controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Confirme o PIN')),
            if (_error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Gerar Carteira')),
          ] else ...[
            const Text(
                'Seed gerada – ANOTE e guarde em local seguro. Não será mostrada novamente.',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SelectableText(_generatedSeed!,
                style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _confirmSaved,
                child: const Text('Já anotei a seed, continuar')),
          ],
        ]),
      ),
    );
  }
}
