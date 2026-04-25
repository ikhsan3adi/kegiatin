import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';

class CreateEventInput {
  final String title;
  final String description;
  final EventType type;
  final EventVisibility visibility;
  final String location;
  final String contactPerson;
  final String? imageUrl;
  final List<SessionInput> sessions;

  const CreateEventInput({
    required this.title,
    required this.description,
    required this.type,
    required this.visibility,
    required this.location,
    required this.contactPerson,
    this.imageUrl,
    required this.sessions,
  });
}
