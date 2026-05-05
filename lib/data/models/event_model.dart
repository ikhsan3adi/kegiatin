import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/data/models/session_model.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
abstract class EventModel with _$EventModel {
  const EventModel._();

  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required EventType type,
    required EventStatus status,
    required EventVisibility visibility,
    required String location,
    required String contactPerson,
    String? imageUrl,
    required String createdBy,
    @Default([]) List<SessionModel> sessions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

  Event toEntity() => Event(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        visibility: visibility,
        location: location,
        contactPerson: contactPerson,
        imageUrl: imageUrl,
        createdBy: createdBy,
        sessions: sessions.map((s) => s.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
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
        createdBy: createdBy,
        sessions: sessions.map((s) => s.toModel()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
