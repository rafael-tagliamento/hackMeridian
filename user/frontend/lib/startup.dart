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
    final wallet = await _security.hasWallet();
    final trusted = await _security.isTrusted();
    final user = await _userStorage.load();
    setState(() {
      _hasWallet = wallet;
      _trusted = trusted;
      _user = user;
      _loading = false;
    });
  }

  void _onWalletCreated(User user) {
    setState(() {
      _hasWallet = true;
      _trusted = true;
      _user = user;
    });
  }

  void _onUnlocked() {
    setState(() {
      _trusted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_hasWallet) {
      return CreateAccount(
        onCreateAccount: _onWalletCreated,
      );
    }
    if (_trusted) {
      return App(initialUser: _user); // inicializa app já logado
    }
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
