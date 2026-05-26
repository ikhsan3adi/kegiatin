class DateFormatter {
  static const List<String> abbreviatedMonths = [
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

  static String formatDateShort(DateTime dt) {
    return '${dt.day} ${abbreviatedMonths[dt.month - 1]} ${dt.year}';
  }
}
