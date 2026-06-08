enum NotificationType {
  eventCreated('EVENT_CREATED'),
  sessionUpdated('SESSION_UPDATED'),
  reminder('REMINDER');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromValue(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.eventCreated,
    );
  }
}
