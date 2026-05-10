import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/presentation/controllers/event/complete_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/publish_event_controller.dart';
import 'package:kegiatin/presentation/controllers/event/start_event_controller.dart';

class AdminEventDetailBottomBar extends ConsumerWidget {
  const AdminEventDetailBottomBar({
    super.key,
    required this.event,
    required this.isPublishing,
    required this.isStarting,
    required this.isCompleting,
  });

  final Event event;
  final bool isPublishing;
  final bool isStarting;
  final bool isCompleting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDraft = event.status == EventStatus.draft;
    final isPublished = event.status == EventStatus.published;
    final isOngoing = event.status == EventStatus.ongoing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Simulasi: Pergi ke edit...')));
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isDraft) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isPublishing
                      ? null
                      : () {
                          ref.read(publishEventControllerProvider.notifier).publish(event.id);
                        },
                  icon: isPublishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.publish_rounded, size: 18),
                  label: Text(isPublishing ? 'Loading...' : 'Publish'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isPublished) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isStarting
                      ? null
                      : () {
                          ref.read(startEventControllerProvider.notifier).start(event.id);
                        },
                  icon: isStarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(isStarting ? 'Loading...' : 'Mulai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isOngoing) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: isCompleting
                      ? null
                      : () {
                          ref.read(completeEventControllerProvider.notifier).complete(event.id);
                        },
                  icon: isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(isCompleting ? 'Loading...' : 'Selesai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Simulasi: Kegiatan dihapus...')));
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(0, 0),
              ),
              child: const Icon(Icons.delete_outline, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
