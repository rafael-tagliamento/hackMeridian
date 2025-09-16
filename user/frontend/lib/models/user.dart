class User {
  final String name;
  final String birthDate;
  final String cpf;
  final String publicKey;
  final String? email;

  const User({
    required this.name,
    required this.birthDate,
    required this.cpf,
    required this.publicKey,
    this.email,
  });
}
