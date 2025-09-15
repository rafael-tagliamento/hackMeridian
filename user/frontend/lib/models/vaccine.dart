class Vaccine {
  final String id;
  final String name;
  final String date; // yyyy-MM-dd
  final String? nextDose;
  final String batch;
  final String location;
  final String doctor;
  final String administrationHash; // Código para administrar a vacina
  final String verificationHash;   // Código para comprovar a vacinação

  const Vaccine({
    required this.id,
    required this.name,
    required this.date,
    this.nextDose,
    required this.batch,
    required this.location,
    required this.doctor,
    required this.administrationHash,
    required this.verificationHash,
  });
}
