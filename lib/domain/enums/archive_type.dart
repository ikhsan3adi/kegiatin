/// Jenis arsip digital per sesi kegiatan.
enum ArchiveType {
  /// Materi kajian (PDF, link).
  material,

  /// Dokumentasi foto.
  photo,

  /// Notulensi atau evaluasi.
  evaluation;

  String toJson() => name.toUpperCase();

  static ArchiveType fromJson(String value) =>
      ArchiveType.values.firstWhere((e) => e.name == value.toLowerCase());
}
