import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final void Function(User) onLogin;
  final VoidCallback onCreateAccount;
  const LoginPage({super.key, required this.onLogin, required this.onCreateAccount});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController(text: '2000-01-01');

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    cpf.dispose();
    birth.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.isEmpty || email.text.isEmpty || cpf.text.isEmpty) return;
    widget.onLogin(
      User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.text.trim(),
        email: email.text.trim(),
        birthDate: birth.text.trim(),
        cpf: cpf.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com degradê
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFC89DFF), // lilás
                  Color(0xFFFEF2FA), // branco
                ],
              ),
            ),
          ),

          // LOGO como plano de fundo no lado direito
          IgnorePointer(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: size.width * 0.55,
                height: size.height,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/logoroxometade.png',
                      width: size.width * 0.9,
                      height: size.height * 0.9,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.62, // ocupa mais que metade, como você preferiu
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  // Faz o conteúdo ocupar ao menos a altura da tela → permite Spacer()
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 180), // 👈 aumenta/diminui esse valor para regular a margem do topo
                              const BigTitle(),        // título grande
                              const SizedBox(height: 16),

                              const Spacer(),         // empurra o formulário para baixo 👇

                              // Formulário
                              TextField(
                                controller: name,
                                decoration: const InputDecoration(labelText: 'Nome completo'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: cpf,
                                decoration: const InputDecoration(labelText: 'CPF'),
                              ),
                              const SizedBox(height: 24),

                              FilledButton(
                                onPressed: submit,
                                child: const Text('Entrar'),
                              ),
                              const SizedBox(height: 12),

                              TextButton(
                                onPressed: widget.onCreateAccount,
                                child: const Text(
                                  'Criar conta',
                                  style: TextStyle(color: Color(0xFF000000)), // preto
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BigTitle extends StatelessWidget {
  const BigTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARTEIRA DE',
          softWrap: false,               // não quebra
          overflow: TextOverflow.visible, // deixa passar se não couber
          style: GoogleFonts.archivoBlack(
            fontSize: 40,                // gigante, fixo
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
            height: 1.1,
          ),
        ),
        Text(
          'VACINAÇÃO',
          softWrap: false,
          overflow: TextOverflow.visible,
          style: GoogleFonts.archivoBlack(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
            height: 1.1,
          ),
        ),
        Text(
          'DIGITAL',
          softWrap: false,
          overflow: TextOverflow.visible,
          style: GoogleFonts.archivoBlack(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
