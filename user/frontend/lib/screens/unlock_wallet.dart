import 'package:flutter/material.dart';
import '../utils/security_service.dart';
import '../widgets/pin_input_boxes.dart';

class UnlockWalletScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;
  final VoidCallback onNeedCreate;
  const UnlockWalletScreen(
      {super.key,
      required this.securityService,
      required this.onUnlocked,
      required this.onNeedCreate});
  @override
  State<UnlockWalletScreen> createState() => _UnlockWalletScreenState();
}

class _UnlockWalletScreenState extends State<UnlockWalletScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _biometricTried = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final hasPin = await widget.securityService.hasPin();
    if (!hasPin) return; // se não tem PIN, fluxo errado
    final ok = await widget.securityService.authenticateBiometric();
    if (ok && mounted) {
      await widget.securityService.markTrusted();
      widget.onUnlocked();
    }
    setState(() => _biometricTried = true);
  }

  Future<void> _submitPin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await widget.securityService
        .authenticateWithPin(_pinController.text.trim());
    if (ok && mounted) {
      await widget.securityService.markTrusted();
      widget.onUnlocked();
    } else {
      setState(() => _error = 'PIN incorreto ou bloqueado.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desbloquear Carteira')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Digite seu PIN para acessar sua carteira Stellar',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(height: 72, child: Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                PinInputBoxes(
                  length: 6,
                  controller: _pinController,
                  obscure: true,
                  onCompleted: (_) => _submitPin(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ]
              ],),
            ))),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _submitPin,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Desbloquear'),
            ),
            const Spacer(),
            if (!_biometricTried) const Text('Verificando biometria...'),
            TextButton(
                onPressed: widget.onNeedCreate,
                child: const Text('Criar nova carteira')),
          ],
        ),
      ),
    );
  }
}
