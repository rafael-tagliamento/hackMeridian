// lib/screens/scan_health_center.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/stellar_crypto.dart';
import '../utils/stellar.dart';

/// Generic QR scanner that validates Stellar signatures in the payload.
class ScanQRCode extends StatefulWidget {
  /// Callback called when signed data has been verified and approved.
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

    _handled = true; // avoid multiple dialogs
    // First, try to decode JSON
    dynamic parsed;
    try {
      parsed = jsonDecode(raw);
    } catch (_) {
      parsed = null;
    }

    if (!mounted) return;

    if (parsed == null) {
      await _showInfo(
        title: 'QR read (text)',
        message: raw,
      );
      _handled = false;
      return;
    }

    // If it's an object with data+signature, validate the signature
    if (parsed is Map &&
        parsed.containsKey('data') &&
        parsed.containsKey('signature')) {
      final keyManager = StellarKeyManager();
      final crypto = StellarCrypto(keyManager);
      final signedJson = raw;
      final valid = crypto.verifySignedJsonString(signedJson);
      if (!valid) {
        await _showInfo(
            title: 'Invalid signature',
            message: 'The QR signature could not be verified.');
        _handled = false;
        return;
      }

      final data = Map<String, dynamic>.from(parsed['data'] as Map);
      // Show data preview and ask for approval
      final approved = await _showVerifiedDataAndConfirm(data);
      if (!mounted) return;
      if (approved == true) {
        // Callback to caller with verified data
        widget.onDataVerified?.call(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data verified and approved.')),
        );
        Navigator.of(context).maybePop();
      } else {
        _handled = false;
      }
      return;
    }

    // If JSON but not the expected signed format, show its content
    await _showInfo(
      title: 'QR JSON read',
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
            child: const Text('Close'),
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
        title: const Text('Verified data'),
        content: SingleChildScrollView(child: Text(sb.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Reject'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  /// 🔹 new: help dialog
  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How scanning works'),
        content: const SingleChildScrollView(
          child: Text(
            'This QR Code contains the user’s vaccination data and a cryptographic signature generated from their private key. By scanning it, other people can check the vaccination record, since the app validates the signature with the user’s public key.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simple UI: camera + frame + controls (help / flash / switch camera)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Wallet'),
        actions: [
          IconButton(
            onPressed: _showHelp, // ⬅️ help button
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flash',
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch camera',
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
          // Fixed tip
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
                'Point the camera at the QR.\n'
                    'When a valid QR is recognized, a confirmation to add will be shown.',
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
