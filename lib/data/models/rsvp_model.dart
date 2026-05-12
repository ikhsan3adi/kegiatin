import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';

part 'rsvp_model.freezed.dart';
part 'rsvp_model.g.dart';

/// Data model untuk [Rsvp] — memetakan `RsvpResponse` dari API.
@freezed
abstract class RsvpModel with _$RsvpModel implements Rsvp {
  const RsvpModel._();

  const factory RsvpModel({
    required String id,
    required String userId,
    required String eventId,
    required String qrToken,
    required RsvpStatus status,
    required DateTime createdAt,
  }) = _RsvpModel;

  factory RsvpModel.fromJson(Map<String, dynamic> json) =>
      _$RsvpModelFromJson(json);
}
