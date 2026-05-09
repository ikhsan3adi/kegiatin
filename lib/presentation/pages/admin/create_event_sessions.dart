import 'package:flutter/material.dart';

/// Header label di atas daftar jadwal sesi.
///
/// Saat [isCustom] true, tampilkan badge "Ketuk untuk ubah".
class SessionListHeader extends StatelessWidget {
  const SessionListHeader({super.key, required this.count, required this.isCustom});

  final int count;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Jadwal Sesi ($count pertemuan)',
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        if (isCustom) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 10, color: colorScheme.onTertiaryContainer),
                const SizedBox(width: 3),
                Text(
                  'Ketuk untuk ubah',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Grid tiga kolom untuk menampilkan daftar tanggal sesi.
///
/// Mode Custom ([isCustom] true): setiap chip bisa diedit dengan tap
/// yang memanggil [onEdit] dengan index yang di-tap.
/// Mode lain: chip hanya tampil sebagai indikator statis.
class SessionDateGrid extends StatelessWidget {
  const SessionDateGrid({
    super.key,
    required this.sessions,
    required this.isCustom,
    required this.onEdit,
    required this.formatDate,
  });

  final List<DateTime> sessions;
  final bool isCustom;
  final void Function(int index) onEdit;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Susun grid 3 kolom secara manual agar shrinkWrap berjalan baik
    // di dalam SingleChildScrollView.
    final rows = <Widget>[];
    for (int i = 0; i < sessions.length; i += 3) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: SessionChip(
                  index: i,
                  date: sessions[i],
                  isCustom: isCustom,
                  onTap: () => onEdit(i),
                  formatDate: formatDate,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 5),
              if (i + 1 < sessions.length)
                Expanded(
                  child: SessionChip(
                    index: i + 1,
                    date: sessions[i + 1],
                    isCustom: isCustom,
                    onTap: () => onEdit(i + 1),
                    formatDate: formatDate,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 5),
              if (i + 2 < sessions.length)
                Expanded(
                  child: SessionChip(
                    index: i + 2,
                    date: sessions[i + 2],
                    isCustom: isCustom,
                    onTap: () => onEdit(i + 2),
                    formatDate: formatDate,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

/// Satu chip sesi.
///
/// Jika [isCustom] true: chip berwarna `secondaryContainer`, tappable,
/// dan menampilkan icon pensil kecil.
/// Jika [isCustom] false: chip berwarna `primaryContainer`, statis.
class SessionChip extends StatelessWidget {
  const SessionChip({
    super.key,
    required this.index,
    required this.date,
    required this.isCustom,
    required this.onTap,
    required this.formatDate,
    required this.colorScheme,
    required this.textTheme,
  });

  final int index;
  final DateTime date;
  final bool isCustom;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bg = isCustom ? colorScheme.secondaryContainer : colorScheme.primaryContainer;
    final fg = isCustom ? colorScheme.onSecondaryContainer : colorScheme.onPrimaryContainer;

    final chip = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isCustom
            ? Border.all(color: colorScheme.secondary.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.15), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              formatDate(date),
              style: textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCustom) Icon(Icons.edit_outlined, size: 11, color: fg.withValues(alpha: 0.7)),
        ],
      ),
    );

    if (!isCustom) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: chip),
    );
  }
}
