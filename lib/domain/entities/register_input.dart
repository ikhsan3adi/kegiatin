class RegisterInput {
  final String email;
  final String password;
  final String displayName;
  final String userType; // 'ANGGOTA' | 'UMUM'
  final String? npa;
  final String? cabang;

  const RegisterInput({
    required this.email,
    required this.password,
    required this.displayName,
    required this.userType,
    this.npa,
    this.cabang,
  });
}
