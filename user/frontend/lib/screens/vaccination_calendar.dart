import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vaccine.dart';
import '../utils/vaccine_alerts.dart';

class VaccinationCalendar extends StatelessWidget {
  final User user;
  final List<Vaccine> vaccines;
  const VaccinationCalendar({super.key, required this.user, required this.vaccines});

  Color _statusColor(String? nextDose) {
    if (nextDose == null) return Colors.grey;
    final today = DateTime.now();
    final nd = DateTime.tryParse(nextDose);
    if (nd == null) return Colors.grey;
    if (nd.isBefore(today)) return Colors.red;
    if (nd.difference(today).inDays <= 10) return Colors.orange;
    return Colors.green;
  }

  String _statusText(String? nextDose) {
    if (nextDose == null) return 'Dose única / sem próxima dose registrada';
    final today = DateTime.now();
    final nd = DateTime.tryParse(nextDose);
    if (nd == null) return 'Próxima dose: data inválida';
    final diff = nd.difference(today).inDays;
    if (diff < 0) return 'Em atraso desde $nextDose';
    if (diff == 0) return 'Próxima dose: hoje';
    if (diff <= 10) return 'Próxima dose em $diff dia(s) • $nextDose';
    return 'Próxima dose: $nextDose';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...vaccines]..sort((a,b){
      final ad = DateTime.tryParse(a.nextDose ?? '') ?? DateTime(2100);
      final bd = DateTime.tryParse(b.nextDose ?? '') ?? DateTime(2100);
      return ad.compareTo(bd);
    });

    final alerts = getVaccineAlerts(vaccines);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (alerts.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Alertas', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (final a in alerts.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• ${a.vaccine.name}: ${a.message}'),
                  ),
              ]),
            ),
          ),
        const SizedBox(height: 12),
        ...sorted.map((v) => Card(
          child: ListTile(
            title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aplicada em: ${v.date}'),
              Text('Lote: ${v.batch} • Local: ${v.location} • Profissional: ${v.doctor}'),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(v.nextDose).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(_statusText(v.nextDose),
                    style: TextStyle(color: _statusColor(v.nextDose), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ]),
            ]),
            trailing: const Icon(Icons.qr_code_2),
          ),
        )),
      ],
    );
  }
}
