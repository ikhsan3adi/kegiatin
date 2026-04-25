/// Tipe kegiatan.
enum EventType {
  /// Kegiatan sekali jalan — harus memiliki tepat 1 sesi eksplisit.
  single,

  /// Kegiatan rutin/berseri — memiliki banyak sesi.
  series;

  String toJson() => name.toUpperCase();

  static EventType fromJson(String value) =>
      EventType.values.firstWhere((e) => e.name == value.toLowerCase());
}
