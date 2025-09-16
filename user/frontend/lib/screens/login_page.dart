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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final name = TextEditingController();
  final email = TextEditingController();
  final cpf = TextEditingController();
  final birth = TextEditingController(text: '2000-01-01');

  late final AnimationController _ctrl;
  late final Animation<Offset> _titleSlide; // desce
  late final Animation<double> _titleFade;
  late final Animation<Offset> _logoSlide;  // sobe
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    ));
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    cpf.dispose();
    birth.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // QUALQUER LOGIN ENTRA (modo permissivo)  // <<<
  void submit() {
    final n = name.text.trim().isEmpty ? 'Usuário' : name.text.trim();          // <<<
    final e = email.text.trim();                                                // <<<
    final c = cpf.text.trim().isEmpty ? '00000000000' : cpf.text.trim();        // <<<
    final b = birth.text.trim().isEmpty ? '2000-01-01' : birth.text.trim();     // <<<

    widget.onLogin(
      User(
        name: n,
        email: e.isEmpty ? null : e,   // ✅ aqui estava o erro
        birthDate: b,
        cpf: c,
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

          // LOGO como plano de fundo no lado direito (entra SUBINDO)
          IgnorePointer(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: size.width * 0.55,
                height: size.height,
                child: ClipRect(
                  child: SlideTransition(
                    position: _logoSlide,
                    child: FadeTransition(
                      opacity: _logoFade,
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
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.62,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 180),

                              // TÍTULO (entra DESCENDO)
                              SlideTransition(
                                position: _titleSlide,
                                child: FadeTransition(
                                  opacity: _titleFade,
                                  child: const BigTitle(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              const Spacer(),

                              // Formulário (pode ficar tudo vazio; vai entrar mesmo assim)  // <<<
                              TextField(
                                controller: name,
                                decoration: const InputDecoration(labelText: 'Nome completo'),
                                onSubmitted: (_) => submit(), // Enter envia     // <<<
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: cpf,
                                decoration: const InputDecoration(labelText: 'CPF'),
                                onSubmitted: (_) => submit(), // Enter envia     // <<<
                              ),
                              const SizedBox(height: 24),

                              FilledButton(
                                onPressed: submit, // sem verificação          // <<<
                                child: const Text('Entrar'),
                              ),
                              const SizedBox(height: 12),

                              TextButton(
                                onPressed: widget.onCreateAccount,
                                child: const Text(
                                  'Criar conta',
                                  style: TextStyle(color: Color(0xFF000000)),
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
    // Título grande em 3 linhas
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARTEIRA DE',
          softWrap: false,
          overflow: TextOverflow.visible,
          style: GoogleFonts.archivoBlack(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF000000),
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
            color: const Color(0xFF000000),
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
            color: const Color(0xFF000000),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}