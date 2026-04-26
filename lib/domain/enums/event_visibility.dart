import 'package:json_annotation/json_annotation.dart';

enum EventVisibility {
  @JsonValue('OPEN')
  open,

  @JsonValue('INVITE_ONLY')
  inviteOnly;
}
