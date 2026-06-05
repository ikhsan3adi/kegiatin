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
    final local = dt.toLocal();
    return '${local.day} ${abbreviatedMonths[local.month - 1]} ${local.year}';
  }
}
