import 'package:flutter/material.dart';
import 'utils/stellar.dart';
import 'utils/security_service.dart';
import 'screens/unlock_wallet.dart';
import 'screens/create_account.dart';
import 'models/user.dart';
import 'utils/user_storage.dart';
import 'main.dart' show App; // para passar initialUser

class StartupFlow extends StatefulWidget {
  const StartupFlow({super.key});
  @override
  State<StartupFlow> createState() => _StartupFlowState();
}

class _StartupFlowState extends State<StartupFlow> {
  late final StellarKeyManager _keyManager;
  late final SecurityService _security;
  late final UserStorage _userStorage;
  bool _loading = true;
  bool _hasWallet = false;
  bool _trusted = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _keyManager = StellarKeyManager();
    _security = SecurityService(keyManager: _keyManager);
    _userStorage = UserStorage();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint('[StartupFlow] bootstrap: iniciando');
    final wallet = await _security.hasWallet();
    final trusted = await _security.isTrusted();
    final user = await _userStorage.load();
    debugPrint(
        '[StartupFlow] bootstrap: wallet=$wallet trusted=$trusted user=${user != null} mounted=$mounted');
    if (!mounted) {
      debugPrint(
          '[StartupFlow] bootstrap: widget not mounted, skipping setState');
      return;
    }
    setState(() {
      _hasWallet = wallet;
      _trusted = trusted;
      _user = user;
      _loading = false;
    });
  }

  void _onWalletCreated(User user) {
    debugPrint(
        '[StartupFlow] onWalletCreated: user=${user.name} cpf=${user.cpf} pk=${user.publicKey} mounted=$mounted');
    if (!mounted) {
      debugPrint('[StartupFlow] onWalletCreated: widget not mounted, ignoring');
      return;
    }
    setState(() {
      _hasWallet = true;
      _trusted = true;
      _user = user;
    });
  }

  void _onUnlocked() {
    debugPrint('[StartupFlow] onUnlocked called mounted=$mounted');
    if (!mounted) {
      debugPrint('[StartupFlow] onUnlocked: widget not mounted, ignoring');
      return;
    }
    setState(() {
      _trusted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[StartupFlow] build: loading=$_loading hasWallet=$_hasWallet trusted=$_trusted user=${_user != null}');
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_hasWallet) {
      return CreateAccount(
        onCreateAccount: _onWalletCreated,
      );
    }

    // Se já existe um usuário armazenado, force tela de desbloqueio
    if (_user != null && !_trusted) {
      return UnlockWalletScreen(
        securityService: _security,
        onUnlocked: _onUnlocked,
        onNeedCreate: () => setState(() {
          _hasWallet = false;
          _trusted = false;
          _user = null;
        }),
      );
    }

    if (_trusted) {
      return App(initialUser: _user); // inicializa app já logado
    }

    // fallback: pedir desbloqueio por padrão
    return UnlockWalletScreen(
      securityService: _security,
      onUnlocked: _onUnlocked,
      onNeedCreate: () => setState(() {
        _hasWallet = false;
        _trusted = false;
        _user = null;
      }),
    );
  }
}
