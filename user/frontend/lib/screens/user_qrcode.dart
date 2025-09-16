import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user.dart';
import '../services/stellar_crypto.dart';
import '../utils/stellar.dart';

class UserQRCode extends StatelessWidget {
  final User user;

  // Fixed palette (your colors)
  static const Color _roxoEscuro = Color(0xff553b71);
  static const Color _branco = Color(0xfff9f1f9);

  final Color backgroundColor;
  final Color moduleColor;
  final Color eyeColor;

  // Logo (outside the card, placed higher)
  final String logoAsset;
  final double logoWidth;
  final double logoTopPadding;

  // Spacings
  final double titleGap;
  final double logoTitleGap;

  const UserQRCode({
    super.key,
    required this.user,
    this.backgroundColor = _roxoEscuro,
    this.moduleColor = _branco,
    this.eyeColor = _branco,
    this.logoAsset = 'assets/logoroxo2.png',
    this.logoWidth = 120,
    this.logoTopPadding = 1,
    this.titleGap = 16,
    this.logoTitleGap = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Build the data to be signed
    final data = {
      'name': user.name,
      'cpf': user.cpf,
      'publicKey': user.publicKey,
    };

    // note: asynchronous operation; we use FutureBuilder to get the signed payload
    final keyManager = StellarKeyManager();
    final crypto = StellarCrypto(keyManager);

    return Container(
      // Screen background with your palette (lilac → white)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_branco, _branco],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO — outside the card, placed higher
                  SizedBox(height: logoTopPadding),
                  Center(
                    child: Image.asset(
                      logoAsset,
                      width: logoWidth,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: logoTitleGap),

                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'User Identity',
                          textAlign: TextAlign.center,
                          style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _roxoEscuro,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Help',
                          icon: const Icon(Icons.help_outline),
                          color: _roxoEscuro,
                          onPressed: () => _showHelp(context),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: titleGap),

                  // CARD + QR — card has the same color as the QR background
                  Card(
                    color: backgroundColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Centered QR — waits for the signed payload
                          FutureBuilder<String>(
                            future: crypto.signMapAsJson(data),
                            builder: (ctx, snap) {
                              if (snap.connectionState !=
                                  ConnectionState.done) {
                                return const SizedBox(
                                  height: 240,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              if (snap.hasError || snap.data == null) {
                                return SizedBox(
                                  height: 240,
                                  child:
                                  Center(child: Text('Error generating QR')),
                                );
                              }
                              final signedPayload = snap.data!;
                              return QrImageView(
                                data: signedPayload,
                                version: QrVersions.auto,
                                size: 240,
                                gapless: true,
                                backgroundColor: backgroundColor, // == card
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: eyeColor,
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: moduleColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _branco,
        title: const Text('What is this QR Code?'),
        content: const Text(
          'This QR Code represents your "User Identity": name, CPF, email, and date of birth, '
              'encoded in JSON for quick reading by authorized apps.\n\n'
              'Privacy: the content is not encrypted. Share only with trusted services.',
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
}
