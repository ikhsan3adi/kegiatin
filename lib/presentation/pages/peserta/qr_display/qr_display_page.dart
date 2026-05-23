import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';

class PesertaQrDisplayPage extends ConsumerWidget {
  const PesertaQrDisplayPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final asyncEvent = ref.watch(eventDetailControllerProvider(eventId));
    final myRsvps = ref.watch(myRsvpControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        backgroundColor: colorScheme.surface,
      ),
      body: myRsvps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat RSVP: $e')),
        data: (rsvps) {
          final rsvp = rsvps.where((r) => r.eventId == eventId).firstOrNull;
          if (rsvp == null) {
            return _buildNoRsvp(colorScheme, textTheme);
          }
          return asyncEvent.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _buildQrContent(rsvp, null, colorScheme, textTheme),
            data: (event) => _buildQrContent(rsvp, event, colorScheme, textTheme),
          );
        },
      ),
    );
  }

  Widget _buildNoRsvp(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_outlined, size: 80, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Belum Terdaftar',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum mendaftar ke kegiatan ini',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContent(Rsvp rsvp, Event? event, ColorScheme colorScheme, TextTheme textTheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            if (event != null) ...[
              Text(
                event.title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(rsvp),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${rsvp.createdAt.day.toString().padLeft(2, '0')}/'
                '${rsvp.createdAt.month.toString().padLeft(2, '0')}/'
                '${rsvp.createdAt.year.toString()}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: QrImageView(data: rsvp.qrToken, version: QrVersions.auto, size: 250),
            ),
            const Spacer(),
            Text(
              'Tunjukkan QR ini kepada panitia saat check-in',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(Rsvp rsvp) {
    return switch (rsvp.status) {
      RsvpStatus.confirmed => 'Terdaftar',
      RsvpStatus.cancelled => 'Dibatalkan',
      RsvpStatus.waitlist => 'Antrian',
    };
  }
}
