// lib/screens/scan_health_center.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/user.dart';
import '../models/vaccine.dart';

class ScanHealthCenter extends StatefulWidget {
  final User user;
  final List<Vaccine> vaccines;

  /// Deve bater com a assinatura que você usa no main.dart:
  /// void addVaccine({
  ///   required String name,
  ///   required String date,
  ///   String? nextDose,
  ///   required String batch,
  ///   required String location,
  ///   required String doctor,
  /// })
  final void Function({
  required String name,
  required String date,
  String? nextDose,
  required String batch,
  required String location,
  required String doctor,
  }) onAddVaccine;

  const ScanHealthCenter({
    super.key,
    required this.user,
    required this.vaccines,
    required this.onAddVaccine,
  });

  @override
  State<ScanHealthCenter> createState() => _ScanHealthCenterState();
}

class _ScanHealthCenterState extends State<ScanHealthCenter> {
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

    // Marca como tratado para evitar múltiplos diálogos
    _handled = true;

    // Tenta converter para JSON -> campos de vacina
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (!mounted) return;

    if (data == null) {
      await _showInfo(
        title: 'QR lido (texto)',
        message: raw,
      );
      _handled = false; // permite nova leitura
      return;
    }

    // Extrai campos esperados
    final name = (data['name'] ?? '').toString();
    final date = (data['date'] ?? '').toString();
    final nextDose = (data['nextDose']?.toString().isEmpty ?? true)
        ? null
        : data['nextDose'].toString();
    final batch = (data['batch'] ?? '').toString();
    final location = (data['location'] ?? '').toString();
    final doctor = (data['doctor'] ?? '').toString();

    // Validação mínima
    final camposFaltantes = <String>[];
    if (name.isEmpty) camposFaltantes.add('name');
    if (date.isEmpty) camposFaltantes.add('date');
    if (batch.isEmpty) camposFaltantes.add('batch');
    if (location.isEmpty) camposFaltantes.add('location');
    if (doctor.isEmpty) camposFaltantes.add('doctor');

    if (camposFaltantes.isNotEmpty) {
      await _showInfo(
        title: 'QR inválido',
        message:
        'Faltam campos: ${camposFaltantes.join(', ')}.\n\nConteúdo lido:\n$raw',
      );
      _handled = false; // libera nova leitura
      return;
    }

    // Confirmação para adicionar
    final ok = await _confirmAdd(
      name: name,
      date: date,
      nextDose: nextDose,
      batch: batch,
      location: location,
      doctor: doctor,
    );

    if (!mounted) return;

    if (ok == true) {
      widget.onAddVaccine(
        name: name,
        date: date,
        nextDose: nextDose,
        batch: batch,
        location: location,
        doctor: doctor,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vacina “$name” adicionada com sucesso!')),
      );
      Navigator.of(context).maybePop(); // volta uma tela (opcional)
    } else {
      // Permite tentar outro QR
      _handled = false;
    }
  }

  Future<void> _showInfo({required String title, required String message}) async {
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

  Future<bool?> _confirmAdd({
    required String name,
    required String date,
    String? nextDose,
    required String batch,
    required String location,
    required String doctor,
  }) async {
    final sb = StringBuffer()
      ..writeln('Nome: $name')
      ..writeln('Data: $date')
      ..writeln('Próxima dose: ${nextDose ?? '—'}')
      ..writeln('Lote: $batch')
      ..writeln('Local: $location')
      ..writeln('Profissional: $doctor');

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar esta aplicação?'),
        content: Text(sb.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI simples: câmera + moldura + controles (flash / switch camera)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR no Posto'),
        actions: [
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
                'Aponte a câmera para o QR do paciente/registro.\n'
                    'Ao reconhecer um QR válido, vamos pedir confirmação para adicionar.',
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
