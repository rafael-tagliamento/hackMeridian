class User {
  final String name; // Nome do usuário
  final String? email; // Email do usuário
  final String birthDate;  // Data de nascimento
  final String cpf;  // CPF

  const User({
    required this.name,
    required this.email,
    required this.birthDate,
    required this.cpf,
  });
}
