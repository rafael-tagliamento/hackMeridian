import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vaccine.dart';

class ScanHealthCenter extends StatefulWidget {
  final User user;
  final List<Vaccine> vaccines;
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
  final name = TextEditingController();
  final date = TextEditingController(text: '2024-12-15');
  final nextDose = TextEditingController();
  final batch = TextEditingController();
  final location = TextEditingController(text: 'UBS Centro');
  final doctor = TextEditingController(text: 'Dr(a). Responsável');

  @override
  void dispose() {
    name.dispose(); date.dispose(); nextDose.dispose(); batch.dispose(); location.dispose(); doctor.dispose();
    super.dispose();
  }

  void submit() {
    if (name.text.isEmpty || date.text.isEmpty || batch.text.isEmpty || location.text.isEmpty || doctor.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha os campos obrigatórios')));
      return;
    }
    widget.onAddVaccine(
      name: name.text.trim(),
      date: date.text.trim(),
      nextDose: nextDose.text.trim().isEmpty ? null : nextDose.text.trim(),
      batch: batch.text.trim(),
      location: location.text.trim(),
      doctor: doctor.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vacina adicionada com sucesso!')));
    name.clear(); batch.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Leitura de usuário (simulada)'),
              const SizedBox(height: 8),
              Text('CPF: ${widget.user.cpf}\nNome: ${widget.user.name}'),
              const SizedBox(height: 8),
              const Text('Em produção, substitua por câmera + leitor de QR.'),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cadastrar nova vacina', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome da vacina *')),
              TextField(controller: date, decoration: const InputDecoration(labelText: 'Data de aplicação (yyyy-MM-dd) *')),
              TextField(controller: nextDose, decoration: const InputDecoration(labelText: 'Próxima dose (yyyy-MM-dd)')),
              TextField(controller: batch, decoration: const InputDecoration(labelText: 'Lote *')),
              TextField(controller: location, decoration: const InputDecoration(labelText: 'Local *')),
              TextField(controller: doctor, decoration: const InputDecoration(labelText: 'Profissional *')),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: submit, icon: const Icon(Icons.add), label: const Text('Adicionar vacina')),
            ]),
          ),
        ),
      ],
    );
  }
}
