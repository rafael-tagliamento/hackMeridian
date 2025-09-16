import 'dart:convert';

// import 'package:convert/convert.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import '../utils/stellar.dart';

/// Utilitários para assinar e verificar JSONs usando chaves Ed25519/ Stellar.
class StellarCrypto {
  final StellarKeyManager keyManager;

  StellarCrypto(this.keyManager);

  /// Assina o mapa [data] com a seed armazenada e retorna um objeto JSON
  /// contendo {"data": <data>, "signature": "<base64>"}.
  Future<String> signMapAsJson(Map<String, dynamic> data) async {
    final kp = await keyManager.load();
    if (kp == null) throw StateError('Chave secreta não encontrada');

    // Canonicalizar JSON: determinístico (ordenar chaves)
    final normalized = _normalizeJson(data);
    final bytes = utf8.encode(normalized);

    // stellar_flutter_sdk fornece KeyPair com método sign (interno usa ed25519)
    final signed = kp.sign(bytes);

    final signatureB64 = base64Encode(signed);

    final payload = {
      'data': data,
      'signature': signatureB64,
    };
    return jsonEncode(payload);
  }

  /// Verifica o JSON-string gerado por [signMapAsJson]. Retorna true se
  /// assinatura válida para o campo 'data' com a chave pública embutida
  /// em data['publicKey'].
  bool verifySignedJsonString(String signedJson) {
    final obj = jsonDecode(signedJson);
    if (obj is! Map) return false;
    final data = obj['data'];
    final signature = obj['signature'];
    if (data == null || signature == null) return false;

    final publicKey = (data['publicKey'] ?? '') as String;
    if (publicKey.isEmpty) return false;

    final normalized = _normalizeJson(Map<String, dynamic>.from(data));
    final bytes = utf8.encode(normalized);

    final sigBytes = base64Decode(signature as String);

    try {
      final kp = KeyPair.fromAccountId(publicKey);
      return kp.verify(bytes, sigBytes);
    } catch (_) {
      return false;
    }
  }

  // Normaliza JSON: converte mapa para string JSON com chaves ordenadas para
  // garantir assinatura determinística.
  String _normalizeJson(Map<String, dynamic> m) {
    final sortedKeys = m.keys.toList()..sort();
    final Map<String, dynamic> out = {};
    for (final k in sortedKeys) {
      final v = m[k];
      if (v is Map<String, dynamic>) {
        out[k] = jsonDecode(_normalizeJson(v));
      } else {
        out[k] = v;
      }
    }
    return jsonEncode(out);
  }
}
