import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/presentation/controllers/rsvp/event_rsvp_list_controller.dart';

class AdminRsvpList extends ConsumerWidget {
  const AdminRsvpList({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRsvps = ref.watch(eventRsvpListControllerProvider(eventId));

    return asyncRsvps.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('Gagal memuat peserta: $error'),
        ),
      ),
      data: (result) {
        final rsvps = result.data;
        if (rsvps.isEmpty) {
          return _buildEmpty();
        }
        return _buildList(rsvps, context);
      },
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Belum ada peserta yang mendaftar'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<RsvpWithUser> rsvps, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rsvps.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final rsvp = rsvps[index];
        final user = rsvp.user;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text(user.displayName),
          subtitle: Text(
            [
              if (user.npa != null) 'NPA: ${user.npa}',
              if (user.cabang != null) user.cabang,
            ].join(' • '),
          ),
          trailing: _StatusChip(status: rsvp.status),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RsvpStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, String label) = switch (status) {
      RsvpStatus.confirmed => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        'Hadir',
      ),
      RsvpStatus.cancelled => (colorScheme.errorContainer, colorScheme.onErrorContainer, 'Batal'),
      RsvpStatus.waitlist => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        'Tunggu',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
