import 'package:kegiatin/domain/enums/event_visibility.dart';

class UpdateEventInput {
  final String? title;
  final String? description;
  final EventVisibility? visibility;
  final String? location;
  final String? contactPerson;
  final String? imageUrl;

  const UpdateEventInput({
    this.title,
    this.description,
    this.visibility,
    this.location,
    this.contactPerson,
    this.imageUrl,
  });
}
