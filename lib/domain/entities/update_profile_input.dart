/// Input untuk operasi update profil pengguna.
///
/// Semua field opsional — hanya field yang diisi yang akan dikirim ke server.
/// Sesuai dengan `UpdateProfileDto` di API contract.
class UpdateProfileInput {
  final String? displayName;
  final String? cabang;
  final String? photoUrl;

  const UpdateProfileInput({this.displayName, this.cabang, this.photoUrl});
}
