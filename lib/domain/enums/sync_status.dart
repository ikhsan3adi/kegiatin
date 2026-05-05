import 'package:json_annotation/json_annotation.dart';

enum SyncStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('SYNCING')
  syncing,

  @JsonValue('SYNCED')
  synced,

  @JsonValue('CONFLICT')
  conflict;

  static SyncStatus fromJson(String value) {
    final upper = value.toUpperCase();
    return SyncStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == upper,
      orElse: () => throw ArgumentError('Unknown SyncStatus: $value'),
    );
  }
}
