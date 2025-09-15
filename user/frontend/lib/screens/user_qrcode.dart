import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserQRCode extends StatelessWidget {
  final User user;
  const UserQRCode({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'id': user.id,
      'name': user.name,
      'cpf': user.cpf,
      'email': user.email,
      'birthDate': user.birthDate,
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Identificador do Usuário (QR simulado)', style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                SelectableText(payload, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Dica: adicione qr_flutter para gerar o QR real.', style: TextStyle(fontSize: 12)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
