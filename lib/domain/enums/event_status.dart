/// Lifecycle status sebuah event.
enum EventStatus {
  /// Baru dibuat, belum dipublikasikan.
  draft,

  /// Sudah dipublikasikan, peserta bisa RSVP.
  published,

  /// Sedang berlangsung (sesi aktif).
  ongoing,

  /// Semua sesi selesai.
  completed,

  /// Dibatalkan oleh admin.
  cancelled;

  String toJson() => name.toUpperCase();

  static EventStatus fromJson(String value) =>
      EventStatus.values.firstWhere((e) => e.name == value.toLowerCase());
}
