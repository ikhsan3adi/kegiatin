/// Status sinkronisasi data offline → server.
enum SyncStatus {
  /// Belum dikirim ke server.
  pending,

  /// Sedang dalam proses kirim.
  syncing,

  /// Berhasil tersinkronisasi.
  synced,

  /// Terjadi konflik (mis. duplikat userId+sessionId).
  conflict;

  String toJson() => name.toUpperCase();

  static SyncStatus fromJson(String value) =>
      SyncStatus.values.firstWhere((e) => e.name == value.toLowerCase());
}
