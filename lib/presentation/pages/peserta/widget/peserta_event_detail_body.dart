import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/rsvp/create_rsvp_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';

/// Konten scrollable halaman detail event peserta.
///
/// Menampilkan deskripsi, detail event, dan tombol aksi RSVP/QR
/// di bagian bawah scroll.
class PesertaEventDetailBody extends ConsumerWidget {
  const PesertaEventDetailBody({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Deskripsi Kegiatan',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Visibilitas',
                  value: event.visibility == EventVisibility.open ? 'Publik' : 'Internal',
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Tipe Kegiatan',
                  value: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Narahubung', value: event.contactPerson),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: _PesertaActionButton(event: event),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tombol aksi RSVP / Lihat QR peserta.
///
/// Menampilkan state yang sesuai berdasarkan status RSVP dan status event.
class _PesertaActionButton extends ConsumerWidget {
  const _PesertaActionButton({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final myRsvpAsync = ref.watch(myRsvpControllerProvider);
    final createState = ref.watch(createRsvpControllerProvider);

    final isCreating = createState.isLoading;
    final alreadyRsvp = myRsvpAsync.value?.any((r) => r.eventId == event.id) ?? false;

    if (alreadyRsvp) {
      return _ActionChip(
        icon: Icons.qr_code_2,
        label: 'Lihat QR',
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        onTap: () {
          // TODO: tampilkan QR display
        },
      );
    }

    if (event.status == EventStatus.completed) {
      return _ActionChip(
        icon: Icons.event_busy,
        label: 'Kegiatan Berakhir',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (event.status == EventStatus.ongoing) {
      return _ActionChip(
        icon: Icons.event_busy,
        label: 'Pendaftaran Ditutup',
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
        onTap: null,
      );
    }

    if (isCreating) {
      return _ActionChip(
        icon: Icons.hourglass_top,
        label: 'Mendaftar...',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    if (myRsvpAsync.isLoading) {
      return _ActionChip(
        icon: Icons.assignment_outlined,
        label: 'Daftar Kegiatan',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        onTap: null,
      );
    }

    return _ActionChip(
      icon: Icons.assignment_outlined,
      label: 'Daftar Kegiatan',
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      onTap: () => ref.read(createRsvpControllerProvider.notifier).createRsvp(event.id),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
