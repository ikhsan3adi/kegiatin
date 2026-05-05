import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/session_status.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const SessionModel._();

  const factory SessionModel({
    required String id,
    required String eventId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    required int order,
    required SessionStatus status,
    int? capacity,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Session toEntity() => Session(
        id: id,
        eventId: eventId,
        title: title,
        startTime: startTime,
        endTime: endTime,
        location: location,
        order: order,
        status: status,
        capacity: capacity,
      );
}
