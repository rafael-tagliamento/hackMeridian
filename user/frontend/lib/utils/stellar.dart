import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Gerencia geração e persistência de par de chaves Stellar no storage seguro.
class StellarKeyManager {
  static const _secretKey = 'stellar_secret_seed';
  static const _publicKey = 'stellar_public_key';

  // storage com opções padrão (criptografia por plataforma)
  final FlutterSecureStorage _storage;

  StellarKeyManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Carrega par de chaves existente ou cria um novo e persiste.
  Future<KeyPair> loadOrCreate() async {
    final existingSecret = await _storage.read(key: _secretKey);
    if (existingSecret != null && existingSecret.isNotEmpty) {
      return KeyPair.fromSecretSeed(existingSecret);
    }
    final kp = KeyPair.random();
    await _persistKeyPair(kp);
    return kp;
  }

  /// Carrega o par; retorna null se não existir.
  Future<KeyPair?> load() async {
    final secret = await _storage.read(key: _secretKey);
    if (secret == null) return null;
    return KeyPair.fromSecretSeed(secret);
  }

  /// Remove as chaves (logout / wipe).
  Future<void> delete() async {
    await _storage.delete(key: _secretKey);
    await _storage.delete(key: _publicKey);
  }

  /// Gera novo par substituindo o atual. (Atenção: pode perder fundos se não migrar!)
  Future<KeyPair> rotate() async {
    final kp = KeyPair.random();
    await _persistKeyPair(kp, overwrite: true);
    return kp;
  }

  /// Exporta a seed de forma controlada (exibir backup). Evite logar.
  Future<String?> exportSecretSeed() async => _storage.read(key: _secretKey);

  Future<void> _persistKeyPair(KeyPair kp, {bool overwrite = false}) async {
    final exists = await _storage.read(key: _secretKey);
    if (exists != null && !overwrite) return; // já existe, não sobrescreve
    await _storage.write(key: _secretKey, value: kp.secretSeed);
    await _storage.write(key: _publicKey, value: kp.accountId);
  }
}

/// Serviço utilitário para interagir com Stellar (envio de pagamento simples, etc.)
class StellarService {
  final StellarSDK sdk;
  final Network network;
  final StellarKeyManager keyManager;

  StellarService._(this.sdk, this.network, this.keyManager);

  static StellarService forTestNet(StellarKeyManager keyManager) {
    return StellarService._(StellarSDK.TESTNET, Network.TESTNET, keyManager);
  }

  static StellarService forPublicNet(StellarKeyManager keyManager) {
    return StellarService._(StellarSDK.PUBLIC, Network.PUBLIC, keyManager);
  }

  /// Garante chave criada e retorna public key.
  Future<String> ensureAccount() async {
    final kp = await keyManager.loadOrCreate();
    return kp.accountId;
  }

  /// (Opcional) Fund via FriendBot se testnet.
  Future<bool> friendBotIfNeeded() async {
    if (network == Network.TESTNET) {
      final kp = await keyManager.loadOrCreate();
      try {
        await FriendBot.fundTestAccount(kp.accountId);
        return true;
      } catch (_) {
        return false; // já fundeado ou erro de rede
      }
    }
    return false;
  }

  /// Consulta saldos.
  Future<List<Balance>> balances() async {
    final kp = await keyManager.loadOrCreate();
    final acc = await sdk.accounts.account(kp.accountId);
    return acc.balances;
  }

  /// Envia Lumens para a conta de destino.
  Future<String> sendLumens(
      {required String destination,
      required String amount,
      String? memo}) async {
    final kp = await keyManager.loadOrCreate();
    final sourceAcc = await sdk.accounts.account(kp.accountId);
    final paymentOp =
        PaymentOperationBuilder(destination, AssetTypeNative(), amount).build();
    final tx = TransactionBuilder(sourceAcc)
        .addOperation(paymentOp)
        .addMemo(memo != null ? Memo.text(memo) : Memo.none())
        .build();
    tx.sign(kp, network);
    final resp = await sdk.submitTransaction(tx);
    if (!resp.success) {
      throw Exception('Falha transação: ${resp.extras?.resultCodes}');
    }
    return resp.hash!;
  }
}

/*
USO (ex: em initState de um provider):

final keyManager = StellarKeyManager();
final stellar = StellarService.forTestNet(keyManager);
final publicKey = await stellar.ensureAccount();
await stellar.friendBotIfNeeded();
final bals = await stellar.balances();
print(bals.map((b)=>'${b.assetCode ?? 'XLM'}: ${b.balance}').join(', '));

// Enviar
await stellar.sendLumens(destination: 'G....', amount: '1.5', memo: 'teste');

SEGURANÇA
- NUNCA faça backup automático da seed em texto puro.
- Ofereça tela para usuário anotar seed via exportSecretSeed().
- Evite logs contendo a seed.
- Para logout chame keyManager.delete().
*/
