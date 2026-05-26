import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/domain/enums/event_visibility.dart';
import 'package:kegiatin/presentation/controllers/rsvp/event_rsvp_list_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/pages/admin/widget/invite_member_sheet.dart';

class AdminParticipantsPage extends ConsumerWidget {
  const AdminParticipantsPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rsvpsAsync = ref.watch(eventRsvpListControllerProvider(eventId));
    final eventAsync = ref.watch(eventDetailControllerProvider(eventId));
    final isInviteOnly = eventAsync.asData?.value.visibility == EventVisibility.inviteOnly;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        title: const Text('Kelola Peserta'),
        backgroundColor: colorScheme.surfaceContainer,
        actions: [
          if (isInviteOnly)
            IconButton(
              icon: const Icon(Icons.person_add_alt_rounded),
              tooltip: 'Undang Anggota',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => InviteMemberSheet(eventId: eventId),
                );
              },
            ),
        ],
      ),
      body: rsvpsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal memuat peserta: $error'),
          ),
        ),
        data: (result) {
          final rsvps = result.data;
          if (rsvps.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada peserta terdaftar',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rsvps.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _ParticipantRow(rsvp: rsvps[i]),
          );
        },
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.rsvp});

  final RsvpWithUser rsvp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (statusLabel, statusColor) = switch (rsvp.status) {
      RsvpStatus.confirmed => ('Terkonfirmasi', colorScheme.primary),
      RsvpStatus.waitlist => ('Menunggu', colorScheme.tertiary),
      RsvpStatus.cancelled => ('Batal', colorScheme.error),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              (rsvp.user.displayName.isNotEmpty ? rsvp.user.displayName[0] : '?').toUpperCase(),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rsvp.user.displayName,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (rsvp.user.npa != null)
                  Text(
                    'NPA: ${rsvp.user.npa}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
