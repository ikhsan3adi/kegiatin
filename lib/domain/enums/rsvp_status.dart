/// Status reservasi peserta terhadap sebuah event.
enum RsvpStatus {
  /// Terkonfirmasi — peserta mendapat QR code.
  confirmed,

  /// Dibatalkan oleh peserta.
  cancelled,

  /// Masuk waiting list (jika kuota penuh).
  waitlist;

  String toJson() => name.toUpperCase();

  static RsvpStatus fromJson(String value) =>
      RsvpStatus.values.firstWhere((e) => e.name == value.toLowerCase());
}
