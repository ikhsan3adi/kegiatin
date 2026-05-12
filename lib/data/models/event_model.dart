import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/core/utils/json_utils.dart';
import 'package:kegiatin/data/models/session_model.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
abstract class EventModel with _$EventModel implements Event {
  const EventModel._();

  const factory EventModel({
    required String id,
    required String title,
    @JsonKey(fromJson: stringFromJson) required String description,
    required EventType type,
    required EventStatus status,
    required EventVisibility visibility,
    @JsonKey(fromJson: stringFromJson) required String location,
    @JsonKey(fromJson: stringFromJson) required String contactPerson,
    String? imageUrl,
    int? maxParticipants,
    required String createdBy,
    @Default([]) List<SessionModel> sessions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
}

extension EventX on Event {
  EventModel toModel() => EventModel(
    id: id,
    title: title,
    description: description,
    type: type,
    status: status,
    visibility: visibility,
    location: location,
    contactPerson: contactPerson,
    imageUrl: imageUrl,
    maxParticipants: maxParticipants,
    createdBy: createdBy,
    sessions: sessions.map((s) => s.toModel()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
