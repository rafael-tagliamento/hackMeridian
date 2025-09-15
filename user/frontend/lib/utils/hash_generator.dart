String generateHash(String input) {
  int hash = 0;
  if (input.isEmpty) return hash.toString();
  for (int i = 0; i < input.length; i++) {
    final int char = input.codeUnitAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash.toSigned(32);
  }
  final int absVal = hash.abs();
  final String hex = absVal.toRadixString(16).toUpperCase().padLeft(8, '0');
  return hex;
}

String generateAdministrationHash({
  required String name,
  required String batch,
  required String location,
  required String doctor,
}) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final input = '$name-$batch-$location-$doctor-$ts';
  return 'ADM-${generateHash(input)}';
}

String generateVerificationHash(
  String administrationHash, {
  required String cpf,
  required String name,
}) {
  final input = '$administrationHash-$cpf-$name';
  return 'VRF-${generateHash(input)}';
}

bool validateHash(String hash) {
  return hash.length > 10 && (hash.startsWith('ADM-') || hash.startsWith('VRF-'));
}
