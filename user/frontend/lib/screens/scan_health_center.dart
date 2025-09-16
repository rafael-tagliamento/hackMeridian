// lib/screens/scan_health_center.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/stellar_crypto.dart';
import '../utils/stellar.dart';

/// Scanner genérico de QR que valida assinaturas Stellar no payload.
class ScanQRCode extends StatefulWidget {
  /// Callback chamado quando os dados assinados forem verificados e aprovados.
  final void Function(Map<String, dynamic> data)? onDataVerified;

  const ScanQRCode({
    super.key,
    this.onDataVerified,
  });

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handled = true; // evita múltiplos diálogos
    // Primeiro, tentamos decodificar JSON
    dynamic parsed;
    try {
      parsed = jsonDecode(raw);
    } catch (_) {
      parsed = null;
    }

    if (!mounted) return;

    if (parsed == null) {
      await _showInfo(
        title: 'QR lido (texto)',
        message: raw,
      );
      _handled = false;
      return;
    }

    // Se for um objeto com data+signature, validamos a assinatura
    if (parsed is Map &&
        parsed.containsKey('data') &&
        parsed.containsKey('signature')) {
      final keyManager = StellarKeyManager();
      final crypto = StellarCrypto(keyManager);
      final signedJson = raw;
      final valid = crypto.verifySignedJsonString(signedJson);
      if (!valid) {
        await _showInfo(
            title: 'Assinatura inválida',
            message: 'A assinatura do QR não pôde ser verificada.');
        _handled = false;
        return;
      }

      final data = Map<String, dynamic>.from(parsed['data'] as Map);
      // Mostrar visualização dos dados e pedir aprovação
      final approved = await _showVerifiedDataAndConfirm(data);
      if (!mounted) return;
      if (approved == true) {
        // Callback para o chamador com os dados verificados
        widget.onDataVerified?.call(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados verificados e aprovados.')),
        );
        Navigator.of(context).maybePop();
      } else {
        _handled = false;
      }
      return;
    }

    // Caso seja JSON mas não o formato assinado esperado, mostramos o conteúdo
    await _showInfo(
      title: 'QR JSON lido',
      message: jsonEncode(parsed),
    );
    _handled = false;
  }

  Future<void> _showInfo(
      {required String title, required String message}) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showVerifiedDataAndConfirm(Map<String, dynamic> data) async {
    final sb = StringBuffer();
    data.forEach((k, v) {
      sb.writeln('$k: $v');
    });

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dados verificados'),
        content: SingleChildScrollView(child: Text(sb.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Rejeitar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
  }

  // método _confirmAdd removido — fluxo específico de vacinação não é mais necessário

  /// 🔹 novo: diálogo de ajuda
  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Como funciona o escaneamento'),
        content: const SingleChildScrollView(
          child: Text(
            '1) Aponte a câmera para o QR do paciente/registro.\n'
            '2) Ao reconhecer, o app tenta ler o conteúdo como JSON.\n'
            '3) Se o JSON tiver assinatura válida, você poderá visualizar e aprovar os dados.\n\n'
            'Formato esperado:\n'
            '• JSON com campos de dados dentro de "data" e uma string "signature" (Base64).\n\n'
            'Dicas:\n'
            '• Ative o flash se o ambiente estiver escuro.\n'
            '• Aproxime ou afaste para o QR ficar nítido dentro da moldura.\n'
            '• Se ler texto comum (não-JSON), o app mostra o texto lido.\n\n'
            'Privacidade:\n'
            '• O conteúdo lido é usado somente para preencher os campos e não é enviado para servidores.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI simples: câmera + moldura + controles (ajuda / flash / trocar câmera)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Carteira'),
        actions: [
          IconButton(
            onPressed: _showHelp, // ⬅️ botão de ajuda
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ajuda',
          ),
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flash',
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Trocar câmera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          // Dica fixa
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aponte a câmera para o QR.\n'
                'Ao reconhecer um QR válido, será exibida a confirmação para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
