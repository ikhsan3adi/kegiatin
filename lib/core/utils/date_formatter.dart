const List<String> abbreviatedMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Formats a [DateTime] into a short Indonesian date string, e.g., "24 Mei 2026".
String formatDateShort(DateTime dt) {
  return '${dt.day} ${abbreviatedMonths[dt.month - 1]} ${dt.year}';
}
