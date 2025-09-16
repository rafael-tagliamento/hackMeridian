import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import '../models/user.dart';
import '../utils/local_doc_selfie_verifier.dart'; // << novo import

/// ---------------------------------------------------------------------------
/// TELA: Criação de conta em 2 etapas
/// ---------------------------------------------------------------------------
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
  // Step control
  int _step = 0;

  // Controllers
  final name = TextEditingController();
  final email = TextEditingController(); // pode ficar vazio se seu User permitir
  final cpf = TextEditingController();
  final birth = TextEditingController();
  final pin = TextEditingController();

  // Picked images
  final ImagePicker _picker = ImagePicker();
  XFile? _docImage;
  XFile? _selfieImage;

  // Security & biometrics
  final _auth = LocalAuthentication();
  final _secure = const FlutterSecureStorage();

  bool _busy = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    cpf.dispose();
    birth.dispose();
    pin.dispose();
    super.dispose();
  }

  // ---- Step navigation ----
  void _goBack() {
    if (_step == 0) {
      widget.onBackToLogin();
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
      preferredCameraDevice: preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 85, // reduz tamanho → OCR mais estável/perf
    );
    return x;
  }

  // ---- Finalize: biometric + secure save + device bind + face verify ----
  Future<void> _finishAndCreate() async {
    if (_docImage == null || _selfieImage == null) {
      _showSnack('Envie a foto do documento e a selfie.');
      return;
    }

    setState(() => _busy = true);
    try {
      // BIOMETRIA
      final isSupported = await _auth.isDeviceSupported();
      final canCheck    = await _auth.canCheckBiometrics;
      final types       = await _auth.getAvailableBiometrics();
      debugPrint('bio supported=$isSupported canCheck=$canCheck types=$types');

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
        // Sem biometria no device → aceita só PIN (ou mostre um diálogo próprio)
        bioOk = true;
      }
      if (!bioOk) {
        _showSnack('Autenticação biométrica não confirmada.');
        return;
      }

      // VERIFICAÇÃO DOC x SELFIE (usa seu verificador local)
      debugPrint('Iniciando verificação doc x selfie...');
      final faceOk = await LocalDocSelfieVerifier.instance.verify(
        docPath: _docImage!.path,
        selfiePath: _selfieImage!.path,
        expectedName: name.text,
        expectedCpf: cpf.text,
        expectedBirthDate: birth.text,
      );
      debugPrint('Resultado verificação: $faceOk');
      if (!faceOk) {
        _showSnack('Não foi possível confirmar que a selfie corresponde ao documento.');
        return;
      }

      // … vincular device, salvar PIN, criar usuário (igual ao seu código)
      // ...

    } catch (e) {
      _showSnack('Erro ao concluir: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- Helpers ----
  Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final a = await info.androidInfo;
        return 'android:${a.id ?? a.fingerprint ?? 'unknown'}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final i = await info.iosInfo;
        return 'ios:${i.identifierForVendor ?? 'unknown'}';
      }
    } catch (_) {}
    final fb = base64UrlEncode(_randomBytes(24));
    return 'rnd:$fb';
  }

  List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  // Exemplo didático (trocar por PBKDF2 real em produção)
  List<int> _naivePbkdf2(String pin, List<int> salt, int iterations) {
    var out = utf8.encode(pin) + salt;
    for (int i = 0; i < iterations; i++) {
      out = _sha256(out);
    }
    return out;
  }

  List<int> _sha256(List<int> input) {
    final r = List<int>.from(input);
    for (int i = 0; i < r.length; i++) {
      r[i] = (r[i] ^ 0x5a) & 0xff; // placeholder
    }
    return r;
  }

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

          TextField(
            controller: pin,
            decoration: const InputDecoration(labelText: 'PIN (4 a 6 dígitos)'),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) =>
            const SizedBox.shrink(),
            textInputAction: TextInputAction.done,
          ),
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
