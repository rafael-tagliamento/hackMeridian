import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/security_service.dart';

class UnlockWalletScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;
  final VoidCallback onNeedCreate;

  const UnlockWalletScreen({
    Key? key,
    required this.securityService,
    required this.onUnlocked,
    required this.onNeedCreate,
  }) : super(key: key);

  @override
  State<UnlockWalletScreen> createState() => _UnlockWalletScreenState();
}

class _UnlockWalletScreenState extends State<UnlockWalletScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  String? _error;
  bool _biometricTried = false;
  bool _loading = false;
  bool _navigated = false; // prevent navigating more than once

  late final AnimationController _ctrl;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.30), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );

    // start animation after first frame to avoid timing issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _navigateOnceUnlocked() {
    if (_navigated) return;
    _navigated = true;
    widget.onUnlocked();
  }

  void _navigateOnceNeedCreate() {
    if (_navigated) return;
    _navigated = true;
    widget.onNeedCreate();
  }

  Future<void> _tryBiometric() async {
    try {
      // If there is no PIN registered, this is a fresh device → go create
      final hasPin = await widget.securityService
          .hasPin()
          .timeout(const Duration(seconds: 5));

      if (!hasPin) {
        _navigateOnceNeedCreate();
        return;
      }

      // Attempt biometric
      final ok = await widget.securityService
          .authenticateBiometric()
          .timeout(const Duration(seconds: 10));

      if (ok && mounted) {
        await widget.securityService.markTrusted();
        _navigateOnceUnlocked(); // ✅ go straight to the app
        return;
      }
    } on TimeoutException {
      // fallback to manual PIN
    } catch (_) {
      // fallback to manual PIN
    } finally {
      if (mounted) setState(() => _biometricTried = true);
    }
  }

  Future<void> _submitPin() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();

    final pin = _pinController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (pin.isEmpty || pin.length < 4) {
        throw Exception('Enter a valid PIN.');
      }

      final ok = await widget.securityService
          .authenticateWithPin(pin)
          .timeout(const Duration(seconds: 8));

      if (ok) {
        await widget.securityService.markTrusted();
        _navigateOnceUnlocked(); // ✅ authenticated → go to the app
      } else {
        throw Exception('Incorrect or blocked PIN.');
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = 'Validation timed out. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Authentication failed.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
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

          // Logo on the right
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

          // Content
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
                                  child: const _BigTitle(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Spacer(),

                              // PIN field with label
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'PIN',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                                          fontWeight: FontWeight.w600,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          counterText: '',
                                        ),
                                        onSubmitted: (_) => _submitPin(),
                                      ),
                                    ),
                                    if (_error != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _error!,
                                        style:
                                        const TextStyle(color: Colors.red),
                                      ),
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
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text('Unlock'),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              if (!_biometricTried)
                                const Text('Checking biometrics...'),
                              TextButton(
                                onPressed: widget.onNeedCreate,
                                child: const Text('Create new wallet'),
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

class _BigTitle extends StatelessWidget {
  const _BigTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VACCINATION',
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
          'WALLET',
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
