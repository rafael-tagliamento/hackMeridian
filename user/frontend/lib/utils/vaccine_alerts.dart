import '../models/vaccine.dart';

enum VaccineStatus { upToDate, upcoming, overdue, dueSoon }
enum AlertPriority { high, medium, low }

class VaccineAlert {
  final Vaccine vaccine;
  final VaccineStatus status;
  final int daysUntilDue;
  final String message;
  final AlertPriority priority;

  const VaccineAlert({
    required this.vaccine,
    required this.status,
    required this.daysUntilDue,
    required this.message,
    required this.priority,
  });
}

int getDaysDifference(dynamic date1, [dynamic date2]) {
  final DateTime d1 = date1 is DateTime ? date1 : DateTime.parse(date1.toString());
  final DateTime d2 = (date2 == null)
      ? DateTime.now()
      : (date2 is DateTime ? date2 : DateTime.parse(date2.toString()));
  final diffMs = d1.millisecondsSinceEpoch - d2.millisecondsSinceEpoch;
  final days = diffMs / (1000 * 60 * 60 * 24);
  return days.ceil();
}

VaccineStatus getVaccineStatus(Vaccine vaccine) {
  if (vaccine.nextDose == null || vaccine.nextDose!.trim().isEmpty) {
    return VaccineStatus.upToDate;
  }
  final daysUntilDue = getDaysDifference(vaccine.nextDose!);
  if (daysUntilDue < 0) return VaccineStatus.overdue;
  if (daysUntilDue <= 7) return VaccineStatus.dueSoon;
  if (daysUntilDue <= 30) return VaccineStatus.upcoming;
  return VaccineStatus.upToDate;
}

VaccineAlert? createVaccineAlert(Vaccine vaccine) {
  final status = getVaccineStatus(vaccine);
  final int daysUntilDue =
      (vaccine.nextDose == null || vaccine.nextDose!.trim().isEmpty)
          ? 0
          : getDaysDifference(vaccine.nextDose!);

  String message = '';
  AlertPriority priority = AlertPriority.low;

  switch (status) {
    case VaccineStatus.overdue:
      final daysOverdue = daysUntilDue.abs();
      message = 'Vacina em atraso há $daysOverdue dia${daysOverdue != 1 ? 's' : ''}';
      priority = AlertPriority.high;
      break;
    case VaccineStatus.dueSoon:
      if (daysUntilDue == 0) {
        message = 'Vacina deve ser aplicada hoje';
        priority = AlertPriority.high;
      } else if (daysUntilDue == 1) {
        message = 'Vacina deve ser aplicada amanhã';
        priority = AlertPriority.high;
      } else {
        message = 'Vacina deve ser aplicada em $daysUntilDue dias';
        priority = AlertPriority.medium;
      }
      break;
    case VaccineStatus.upcoming:
      message = 'Próxima dose em $daysUntilDue dias';
      priority = AlertPriority.low;
      break;
    case VaccineStatus.upToDate:
      return null;
  }

  return VaccineAlert(
    vaccine: vaccine,
    status: status,
    daysUntilDue: daysUntilDue,
    message: message,
    priority: priority,
  );
}

List<VaccineAlert> getVaccineAlerts(List<Vaccine> vaccines) {
  final alerts = vaccines
      .map(createVaccineAlert)
      .where((a) => a != null)
      .cast<VaccineAlert>()
      .toList();

  const order = {
    AlertPriority.high: 3,
    AlertPriority.medium: 2,
    AlertPriority.low: 1,
  };

  alerts.sort((a, b) {
    if (order[a.priority] != order[b.priority]) {
      return (order[b.priority] ?? 0) - (order[a.priority] ?? 0);
    }
    return a.daysUntilDue - b.daysUntilDue;
  });

  return alerts;
}

Map<String, int> countAlertsByPriority(List<VaccineAlert> alerts) {
  final counts = {'high': 0, 'medium': 0, 'low': 0};
  for (final a in alerts) {
    switch (a.priority) {
      case AlertPriority.high:
        counts['high'] = (counts['high'] ?? 0) + 1;
        break;
      case AlertPriority.medium:
        counts['medium'] = (counts['medium'] ?? 0) + 1;
        break;
      case AlertPriority.low:
        counts['low'] = (counts['low'] ?? 0) + 1;
        break;
    }
  }
  return counts;
}
