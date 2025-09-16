import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user.dart';

class UserQRCode extends StatelessWidget {
  final User user;

  // Paleta fixa (suas cores)
  static const Color _lilasClaro = Color(0xffd9bafa);
  static const Color _roxoEscuro = Color(0xff553b71);
  static const Color _roxoMedio  = Color(0xff6d538b);
  static const Color _preto      = Colors.black;
  static const Color _branco     = Color(0xfff9f1f9);

  // Cores do QR / Card (card == fundo do QR)
  final Color backgroundColor; // fundo do QR e do Card
  final Color moduleColor;     // “quadradinhos” do QR
  final Color eyeColor;        // “olhos” do QR

  // Logo (fora do card, mais pra cima)
  final String logoAsset;
  final double logoWidth;
  final double logoTopPadding; // espaço do topo da página até o logo

  // Espaçamentos
  final double titleGap;       // espaço entre título/ajuda e o card
  final double logoTitleGap;   // espaço entre logo e título

  const UserQRCode({
    super.key,
    required this.user,
    // Defaults usando sua paleta
    this.backgroundColor = _roxoEscuro,        // melhor legibilidade do QR
    this.moduleColor     = _branco,    // quadradinhos
    this.eyeColor        = _branco,     // olhos
    this.logoAsset       = 'assets/logoroxo2.png',
    this.logoWidth       = 120,
    this.logoTopPadding  = 1,
    this.titleGap        = 16,
    this.logoTitleGap    = 10,
  });

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'name': user.name,
      'cpf': user.cpf,
      'email': user.email,
      'birthDate': user.birthDate,
    });

    return Container(
      // Fundo da tela com sua paleta (lilás → branco)
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
                  // LOGO — fora do card, mais pra cima
                  SizedBox(height: logoTopPadding),
                  Center(
                    child: Image.asset(
                      logoAsset,
                      width: 400,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: logoTitleGap),

                  // TÍTULO + AJUDA — fora do card e centralizados
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Identidade do Usuário',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _roxoEscuro,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ajuda',
                          icon: const Icon(Icons.help_outline),
                          color: _roxoEscuro,
                          onPressed: () => _showHelp(context),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: titleGap),

                  // CARD + QR — card tem a mesma cor do fundo do QR
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
                          // QR centralizado
                          QrImageView(
                            data: payload,
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
        title: const Text('O que é este QR Code?'),
        content: const Text(
          'Este QR Code representa sua “Identidade do Usuário”: nome, CPF, e-mail e data de nascimento, '
              'codificados em JSON para leitura rápida por apps autorizados.\n\n'
              'Privacidade: o conteúdo não é criptografado. Compartilhe apenas com serviços confiáveis.',
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
}
