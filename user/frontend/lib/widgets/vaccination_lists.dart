import 'package:flutter/material.dart';

class VaccineItem {
  final String name;
  final String? date;
  final VaccineStatus status;

  const VaccineItem({required this.name, this.date, required this.status});
}

enum VaccineStatus { applied, pending, overdue }

const List<VaccineItem> mockVaccines = [
  // Applied
  VaccineItem(
      name: 'COVID-19 (1st dose)',
      date: '15/03/2024',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Influenza 2024',
      date: '10/04/2024',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Hepatitis B (1st dose)',
      date: '22/02/2024',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Tetanus (1st dose)',
      date: '05/01/2024',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Pneumococcal 13',
      date: '18/12/2023',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Meningococcal ACWY',
      date: '25/11/2023',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'HPV (1st dose)',
      date: '08/10/2023',
      status: VaccineStatus.applied),
  VaccineItem(
      name: 'Varicella (Chickenpox)',
      date: '12/09/2023',
      status: VaccineStatus.applied),

  // Pending
  VaccineItem(name: 'COVID-19 (2nd dose)', status: VaccineStatus.pending),
  VaccineItem(name: 'Hepatitis B (2nd dose)', status: VaccineStatus.pending),
  VaccineItem(name: 'Tetanus (booster)', status: VaccineStatus.pending),
  VaccineItem(name: 'HPV (2nd dose)', status: VaccineStatus.pending),
  VaccineItem(name: 'Pneumococcal 23', status: VaccineStatus.pending),
  VaccineItem(name: 'Influenza 2025', status: VaccineStatus.pending),
  VaccineItem(name: 'Hepatitis A', status: VaccineStatus.pending),
  VaccineItem(name: 'MMR (Booster)', status: VaccineStatus.pending),

  // Overdue
  VaccineItem(name: 'Yellow Fever', status: VaccineStatus.overdue),
  VaccineItem(name: 'COVID-19 (3rd dose)', status: VaccineStatus.overdue),
  VaccineItem(
      name: 'Tdap (Tetanus, Diphtheria, Pertussis)',
      status: VaccineStatus.overdue),
  VaccineItem(name: 'Hepatitis B (3rd dose)', status: VaccineStatus.overdue),
];

class VaccinationLists extends StatelessWidget {
  final List<VaccineItem> vaccines;

  const VaccinationLists({super.key, this.vaccines = mockVaccines});

  List<VaccineItem> _filter(VaccineStatus status) =>
      vaccines.where((v) => v.status == status).toList();

  Color _statusColor(VaccineStatus status, BuildContext context) {
    switch (status) {
      case VaccineStatus.applied:
        return Colors.green.shade500;
      case VaccineStatus.pending:
        return Colors.yellow.shade800;
      case VaccineStatus.overdue:
        return Colors.red.shade500;
    }
  }

  Icon _statusIcon(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.applied:
        return const Icon(Icons.check_circle, size: 18, color: Colors.green);
      case VaccineStatus.pending:
        return const Icon(Icons.schedule, size: 18, color: Colors.orange);
      case VaccineStatus.overdue:
        return const Icon(Icons.warning_amber, size: 18, color: Colors.red);
    }
  }

  Widget _vaccineCard(BuildContext context, VaccineItem vaccine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
        border: Border(
            left: BorderSide(
                color: _statusColor(vaccine.status, context), width: 4)),
      ),
      child: ListTile(
        leading: _statusIcon(vaccine.status),
        title: Text(vaccine.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: vaccine.date != null
            ? Text('Applied on: ${vaccine.date}',
            style: const TextStyle(fontSize: 12))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final applied = _filter(VaccineStatus.applied);
    final pending = _filter(VaccineStatus.pending);
    final overdue = _filter(VaccineStatus.overdue);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: isWide
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _sectionCard(
                    'Applied', applied, VaccineStatus.applied)),
            const SizedBox(width: 12),
            Expanded(
                child: _sectionCard(
                    'Pending', pending, VaccineStatus.pending)),
            const SizedBox(width: 12),
            Expanded(
                child: _sectionCard(
                    'Overdue', overdue, VaccineStatus.overdue)),
          ],
        )
            : Column(
          children: [
            _sectionCard('Applied', applied, VaccineStatus.applied),
            const SizedBox(height: 12),
            _sectionCard('Pending', pending, VaccineStatus.pending),
            const SizedBox(height: 12),
            _sectionCard('Overdue', overdue, VaccineStatus.overdue),
          ],
        ),
      );
    });
  }

  Widget _sectionCard(
      String title, List<VaccineItem> items, VaccineStatus status) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(status),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: items.isNotEmpty
                  ? ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) =>
                    _vaccineCard(context, items[i]),
              )
                  : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No vaccine ${title.toLowerCase()}',
                      style: const TextStyle(color: Colors.grey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
