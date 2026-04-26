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
}
