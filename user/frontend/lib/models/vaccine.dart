class Vaccine {
  final String id; // Código da vacina
  final String name;  // Nome da vacina
  final String date; // Data (yyyy-MM-dd)
  final String? nextDose; // Quando será a próxima dosagem
  final String batch; // Lote
  final String administrationHash; // Código para administrar a vacina
  final String verificationHash;   // Código para comprovar a vacinação

  const Vaccine({
    required this.id,
    required this.name,
    required this.date,
    this.nextDose,
    required this.batch,
    required this.administrationHash,
    required this.verificationHash,
  });
}
