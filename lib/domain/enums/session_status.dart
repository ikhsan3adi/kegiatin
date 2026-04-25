/// Status lifecycle sebuah sesi kegiatan.
enum SessionStatus {
  /// Terjadwal, belum dimulai.
  scheduled,

  /// Sedang berlangsung.
  ongoing,

  /// Telah selesai.
  completed,

  /// Ditunda.
  postponed;

  String toJson() => name.toUpperCase();

  static SessionStatus fromJson(String value) =>
      SessionStatus.values.firstWhere((e) => e.name == value.toLowerCase());
}
