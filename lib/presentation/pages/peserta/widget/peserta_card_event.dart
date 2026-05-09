import 'package:flutter/material.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';

class CardEvent extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool showActionButton;

  const CardEvent({
    super.key,
    required this.event,
    this.onTap,
    this.showActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ambil sesi pertama untuk info waktu
    final firstSession = event.sessions.isNotEmpty ? event.sessions.first : null;
    final startTime = firstSession?.startTime;
    
    // Format tanggal sederhana: YYYY-MM-DD . HH:mm
    final dateStr = startTime != null 
      ? "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} . ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"
      : 'Waktu belum ditentukan';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Garis Indikator Kiri - Sekarang Dinamis
            Container(
              margin: const EdgeInsets.only(top: 8, right: 16),
              width: 6,
              height: 60,
              decoration: BoxDecoration(
                color: _getStatusColor(event.status, colorScheme),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            // Konten Utama Card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Badge / Label
                  Row(
                    children: [
                      _buildBadge(
                        text: _getStatusText(event.status),
                        backgroundColor: _getStatusColor(event.status, colorScheme).withOpacity(0.2),
                        textColor: _getStatusColor(event.status, colorScheme),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        text: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                        backgroundColor: event.type == EventType.series 
                            ? colorScheme.tertiaryContainer 
                            : colorScheme.secondaryContainer,
                        textColor: event.type == EventType.series 
                            ? colorScheme.onTertiaryContainer 
                            : colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Judul Kegiatan
                  Text(
                    event.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Baris Waktu
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Baris Lokasi
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  if (showActionButton) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(context),
                    ),
                  ],
                ],
              ),
            ),

            // Icon Chevron Kanan
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // Mocking state based on EventStatus for UI purposes
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;

    if (event.status == EventStatus.completed) {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
      text = 'Kehadiran Terverifikasi';
      icon = Icons.verified;
    } else if (event.status == EventStatus.ongoing) {
      bgColor = Colors.lightGreen.shade300;
      textColor = Colors.green.shade800;
      text = 'Lihat QR Saya';
      icon = Icons.qr_code_2;
    } else {
      // Default: Published / Draft
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      text = 'Detail Kegiatan';
      icon = Icons.assignment_outlined;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // Akan diarahkan ke detail atau langsung pop up QR nanti
          if (onTap != null) onTap!();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.draft: return 'Draft';
      case EventStatus.published: return 'Segera';
      case EventStatus.ongoing: return 'Berlangsung';
      case EventStatus.completed: return 'Selesai';
      case EventStatus.cancelled: return 'Batal';
    }
  }

  Color _getStatusColor(EventStatus status, ColorScheme colorScheme) {
    switch (status) {
      case EventStatus.ongoing: 
        return const Color(0xFF2E7D32); // Hijau (Berlangsung)
      case EventStatus.published: 
        return colorScheme.primary; // Warna utama (Segera/Published)
      case EventStatus.completed: 
        return colorScheme.outline; // Abu-abu (Selesai)
      case EventStatus.cancelled: 
        return colorScheme.error; // Merah (Batal)
      default: 
        return colorScheme.secondary;
    }
  }
}
