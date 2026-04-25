/// Visibilitas event — menentukan siapa yang bisa melihat dan RSVP.
enum EventVisibility {
  /// Terbuka untuk semua pengguna.
  open,

  /// Hanya peserta yang diundang.
  inviteOnly;

  /// Serialisasi ke `"OPEN"` atau `"INVITE_ONLY"`.
  String toJson() {
    switch (this) {
      case EventVisibility.open:
        return 'OPEN';
      case EventVisibility.inviteOnly:
        return 'INVITE_ONLY';
    }
  }

  static EventVisibility fromJson(String value) {
    switch (value) {
      case 'OPEN':
        return EventVisibility.open;
      case 'INVITE_ONLY':
        return EventVisibility.inviteOnly;
      default:
        throw ArgumentError('Unknown EventVisibility: $value');
    }
  }
}
