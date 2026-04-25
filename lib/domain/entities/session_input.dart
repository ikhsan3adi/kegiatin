class SessionInput {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final int? capacity;

  const SessionInput({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.capacity,
  });
}
