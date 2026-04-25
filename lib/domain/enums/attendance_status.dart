/// Status kehadiran peserta pada sebuah sesi.
enum AttendanceStatus {
  /// Hadir tepat waktu.
  present,

  /// Hadir tetapi terlambat.
  late,

  /// Tidak hadir.
  absent;

  String toJson() => name.toUpperCase();

  static AttendanceStatus fromJson(String value) =>
      AttendanceStatus.values.firstWhere((e) => e.name == value.toLowerCase());
}
