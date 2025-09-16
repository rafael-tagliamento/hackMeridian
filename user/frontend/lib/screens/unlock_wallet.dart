import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/security_service.dart';

class UnlockWalletScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;
  final VoidCallback onNeedCreate;
  const UnlockWalletScreen(
      {Key? key,
      required this.securityService,
      required this.onUnlocked,
      required this.onNeedCreate})
      : super(key: key);

  @override
  State<UnlockWalletScreen> createState() => _UnlockWalletScreenState();
}

class _UnlockWalletScreenState extends State<UnlockWalletScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  String? _error;
  bool _biometricTried = false;
  bool _loading = false;

  late final AnimationController _ctrl;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();
    _tryBiometric();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.30), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _titleFade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic)));
    _logoFade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.15, 1.0, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final hasPin = await widget.securityService.hasPin();
    if (!hasPin) return;
    final ok = await widget.securityService.authenticateBiometric();
    if (ok && mounted) {
      await widget.securityService.markTrusted();
      widget.onUnlocked();
    }
    if (mounted) setState(() => _biometricTried = true);
  }

  Future<void> _submitPin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await widget.securityService
        .authenticateWithPin(_pinController.text.trim());
    if (ok && mounted) {
      await widget.securityService.markTrusted();
      widget.onUnlocked();
    } else {
      if (mounted) setState(() => _error = 'PIN incorreto ou bloqueado.');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC89DFF), Color(0xFFFEF2FA)],
              ),
            ),
          ),
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
                        child: Image.asset('assets/logoroxometade.png',
                            width: size.width * 0.9,
                            height: size.height * 0.9,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerRight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.62,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 180),
                              SlideTransition(
                                  position: _titleSlide,
                                  child: FadeTransition(
                                      opacity: _titleFade,
                                      child: const _BigTitle())),
                              const SizedBox(height: 16),
                              const Spacer(),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 220,
                                      child: TextField(
                                        controller: _pinController,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        maxLength: 6,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            letterSpacing: 8,
                                            fontWeight: FontWeight.w600),
                                        decoration: const InputDecoration(
                                            counterText: ''),
                                        onSubmitted: (_) => _submitPin(),
                                      ),
                                    ),
                                    if (_error != null) ...[
                                      const SizedBox(height: 8),
                                      Text(_error!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    ],
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                        onPressed: _loading ? null : _submitPin,
                                        child: _loading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2))
                                            : const Text('Desbloquear')),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (!_biometricTried)
                                const Text('Verificando biometria...'),
                              TextButton(
                                  onPressed: widget.onNeedCreate,
                                  child: const Text('Criar nova carteira')),
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

class _BigTitle extends StatelessWidget {
  const _BigTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CARTEIRA DE',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: GoogleFonts.archivoBlack(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF000000),
                height: 1.1)),
        Text('VACINAÇÃO',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: GoogleFonts.archivoBlack(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF000000),
                height: 1.1)),
        Text('DIGITAL',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: GoogleFonts.archivoBlack(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF000000),
                height: 1.1)),
      ],
    );
  }
}
