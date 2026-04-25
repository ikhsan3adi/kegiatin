/// Hak akses pengguna di dalam aplikasi.
enum UserRole {
  /// Pengurus — dapat membuat event, scan QR, upload materi.
  admin,

  /// Anggota atau peserta umum.
  member;

  /// Nilai API: `"ADMIN"` / `"MEMBER"`.
  String toJson() => name.toUpperCase();

  static UserRole fromJson(String value) =>
      UserRole.values.firstWhere((e) => e.name == value.toLowerCase());
}
