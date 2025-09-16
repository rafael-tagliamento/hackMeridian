import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../utils/local_doc_selfie_verifier.dart'; // << novo import
import '../utils/stellar.dart';
import '../utils/security_service.dart';
import '../utils/user_storage.dart';
import '../widgets/pin_input_boxes.dart';

/// ---------------------------------------------------------------------------
/// TELA: Criação de conta em 2 etapas
/// ---------------------------------------------------------------------------
class CreateAccount extends StatefulWidget {
  final void Function(User) onCreateAccount;
  const CreateAccount({
    super.key,
    required this.onCreateAccount,
  });

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // Step control
  int _step = 0;

  // Controllers
  final name = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController();
  final pin = TextEditingController();

  // Picked images
  final ImagePicker _picker = ImagePicker();
  XFile? _docImage;
  XFile? _selfieImage;

  // Security & biometrics
  final _auth = LocalAuthentication();

  bool _busy = false;

  // Durante desenvolvimento, permite pular verificação por foto.
  bool _requireImages = false;

  StellarKeyManager? _keyManager;
  SecurityService? _security;
  String? _seedShown;

  late final UserStorage _userStorage;

  @override
  void initState() {
    super.initState();
    _keyManager = StellarKeyManager();
    _security = SecurityService(keyManager: _keyManager!);
    _userStorage = UserStorage();
  }

  @override
  void dispose() {
    name.dispose();
    cpf.dispose();
    birth.dispose();
    pin.dispose();
    super.dispose();
  }

  // ---- Step navigation ----
  void _goBack() {
    if (_step == 0) {
      return;
    } else {
      setState(() => _step = 0);
    }
  }

  Future<void> _goNext() async {
    if (_step == 0) {
      final ok = _validateStep1();
      if (!ok) return;
      setState(() => _step = 1);
    }
  }

  bool _validateStep1() {
    final errors = <String>[];
    if (name.text.trim().isEmpty) errors.add('Nome');
    if (cpf.text.trim().isEmpty) errors.add('CPF');
    if (birth.text.trim().isEmpty) errors.add('Data de Nascimento');
    final p = pin.text.trim();
    if (p.isEmpty || p.length < 4 || p.length > 6) {
      errors.add('PIN (4 a 6 dígitos)');
    }
    if (errors.isNotEmpty) {
      _showSnack('Preencha: ${errors.join(', ')}');
      return false;
    }
    return true;
  }

  // ---- Image pickers (step 2) ----
  Future<void> _pickDocImage() async {
    final x = await _pickImageWithChoice();
    if (x != null) setState(() => _docImage = x);
  }

  Future<void> _pickSelfieImage() async {
    final x = await _pickImageWithChoice(preferFrontCamera: true);
    if (x != null) setState(() => _selfieImage = x);
  }

  Future<XFile?> _pickImageWithChoice({bool preferFrontCamera = false}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Usar câmera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    // para câmera frontal quando for selfie
    final x = await _picker.pickImage(
      source: source,
      preferredCameraDevice:
          preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 85, // reduz tamanho → OCR mais estável/perf
    );
    return x;
  }

  // ---- Finalize: biometric + secure save + device bind + face verify ----
  Future<void> _finishAndCreate() async {
    // Durante desenvolvimento: permitir criar conta mesmo sem imagens.
    if (_requireImages && (_docImage == null || _selfieImage == null)) {
      _showSnack('Envie a foto do documento e a selfie.');
      return;
    }

    setState(() => _busy = true);
    try {
      // biometria + verificação já existente
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      bool bioOk = false;
      if (isSupported && canCheck && types.isNotEmpty) {
        bioOk = await _auth.authenticate(
          localizedReason: 'Confirme sua identidade',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
      } else {
        bioOk = true;
      }
      if (!bioOk) {
        _showSnack('Autenticação biométrica não confirmada.');
        return;
      }
      bool faceOk = true;
      if (_requireImages && _docImage != null && _selfieImage != null) {
        faceOk = await LocalDocSelfieVerifier.instance.verify(
          docPath: _docImage!.path,
          selfiePath: _selfieImage!.path,
          expectedName: name.text,
          expectedCpf: cpf.text,
          expectedBirthDate: birth.text,
        );
        if (!faceOk) {
          _showSnack('Não foi possível confirmar documento vs selfie.');
          return;
        }
      }
      // Geração carteira + PIN
      final kp = await _keyManager!.loadOrCreate();
      debugPrint('[CreateAccount] generated keypair public=${kp.accountId}');
      await _security!.setPin(pin.text.trim());
      final stellar = StellarService.forTestNet(_keyManager!);
      await stellar.friendBotIfNeeded();
      _seedShown = kp.secretSeed; // exibir uma vez
      final user = User(
          name: name.text.trim(),
          birthDate: birth.text.trim(),
          cpf: cpf.text.trim(),
          publicKey: kp.accountId);
      await _userStorage.save(user);
      debugPrint('[CreateAccount] user saved to storage');
      await _security!.markTrusted();
      debugPrint('[CreateAccount] marked device trusted');
      // Mostra seed em diálogo antes de concluir
      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Backup da Seed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Anote e guarde sua seed. Ela não será mostrada novamente.'),
                const SizedBox(height: 12),
                SelectableText(
                  _seedShown!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Já anotei'),
              )
            ],
          );
        },
      );
      if (!mounted) return;
      widget.onCreateAccount(user); // segue para app já autenticado
    } catch (e, st) {
      debugPrint('[CreateAccount] finish error: $e');
      debugPrint('$st');
      _showSnack('Erro ao concluir: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- Helpers ----
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Criar conta (1/2)' : 'Criar conta (2/2)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : _goBack,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _step == 0
                    ? _StepOne(formKey: const ValueKey(1))
                    : _StepTwo(formKey: const ValueKey(2)),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              if (_step == 1)
                OutlinedButton(
                  onPressed: _busy ? null : () => setState(() => _step = 0),
                  child: const Text('Voltar'),
                ),
              const Spacer(),
              if (_step == 0)
                FilledButton(
                  onPressed: _busy ? null : _goNext,
                  child: const Text('Próxima etapa'),
                ),
              if (_step == 1)
                FilledButton(
                  onPressed: _busy ? null : _finishAndCreate,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Concluir e criar conta'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Step widgets ----
  Widget _StepOne({required Key formKey}) {
    return SingleChildScrollView(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo.png', height: 90),
          const SizedBox(height: 24),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nome completo'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cpf,
            decoration: const InputDecoration(labelText: 'CPF'),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: birth,
            decoration: const InputDecoration(
              labelText: 'Data de Nascimento (yyyy-MM-dd)',
            ),
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // PIN com 6 quadradinhos
          SizedBox(height: 72, child: Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PinInputBoxes(
              length: 6,
              controller: pin,
              obscure: true,
              onChanged: (s) {},
            ),
          ))),
        ],
      ),
    );
  }

  Widget _StepTwo({required Key formKey}) {
    return SingleChildScrollView(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/logo.png', height: 70),
          const SizedBox(height: 16),
          Text(
            'Verificação de identidade',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Envie a foto do documento e uma selfie para conferência.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _UploadTile(
                  label: 'Documento (frente)',
                  file: _docImage,
                  onPick: _pickDocImage,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _UploadTile(
                  label: 'Selfie',
                  file: _selfieImage,
                  onPick: _pickSelfieImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dica: garanta boa iluminação e centralize o rosto/documento.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final XFile? file;
  final VoidCallback onPick;

  const _UploadTile({
    required this.label,
    required this.file,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return InkWell(
      onTap: onPick,
      borderRadius: borderRadius,
      child: Ink(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: file == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.upload_file, size: 32),
                    const SizedBox(height: 8),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text('Toque para enviar',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                )
              : ClipRRect(
                  borderRadius: borderRadius,
                  child: Image.file(
                    File(file!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}
