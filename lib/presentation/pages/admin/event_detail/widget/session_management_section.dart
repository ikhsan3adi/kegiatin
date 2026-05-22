import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/entities/session_input.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/usecases/session/update_session_usecase.dart';
import 'package:kegiatin/presentation/controllers/session/add_session_controller.dart';
import 'package:kegiatin/presentation/controllers/session/delete_session_controller.dart';
import 'package:kegiatin/presentation/controllers/session/update_session_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';

class SessionManagementSection extends ConsumerWidget {
  const SessionManagementSection({super.key, required this.event});

  final Event event;

  bool get _canManage => event.status == EventStatus.draft || event.status == EventStatus.published;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_outlined, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text('Sesi', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_canManage && event.type == EventType.series)
                TextButton.icon(
                  onPressed: () => _showAddSessionDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (event.sessions.isEmpty)
            Text(
              'Belum ada sesi',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            )
          else
            ...event.sessions.map(
              (session) => _SessionTile(
                session: session,
                canManage: _canManage,
                onEdit: () => _showEditSessionDialog(context, ref, session),
                onDelete: () => _confirmDeleteSession(context, ref, session),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddSessionDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime? startDate;
    TimeOfDay? startTime;
    DateTime? endDate;
    TimeOfDay? endTime;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tambah Sesi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nama Sesi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                const SizedBox(height: 8),
                _DatePickerField(
                  label: 'Tanggal Mulai',
                  value: startDate,
                  onPicked: (d) => setDialogState(() => startDate = d),
                ),
                const SizedBox(height: 8),
                _TimePickerField(
                  label: 'Jam Mulai',
                  value: startTime,
                  onPicked: (t) => setDialogState(() => startTime = t),
                ),
                const SizedBox(height: 8),
                _DatePickerField(
                  label: 'Tanggal Selesai',
                  value: endDate,
                  onPicked: (d) => setDialogState(() => endDate = d),
                ),
                const SizedBox(height: 8),
                _TimePickerField(
                  label: 'Jam Selesai',
                  value: endTime,
                  onPicked: (t) => setDialogState(() => endTime = t),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    startDate == null ||
                    startTime == null ||
                    endDate == null ||
                    endTime == null) {
                  return;
                }
                final start = DateTime(
                  startDate!.year,
                  startDate!.month,
                  startDate!.day,
                  startTime!.hour,
                  startTime!.minute,
                );
                final end = DateTime(
                  endDate!.year,
                  endDate!.month,
                  endDate!.day,
                  endTime!.hour,
                  endTime!.minute,
                );
                Navigator.pop(ctx);
                await ref
                    .read(addSessionControllerProvider.notifier)
                    .addSession(
                      event.id,
                      SessionInput(
                        title: titleController.text.trim(),
                        startTime: start,
                        endTime: end,
                        location: locationController.text.trim().isEmpty
                            ? null
                            : locationController.text.trim(),
                      ),
                    );
                ref.invalidate(eventDetailControllerProvider(event.id));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSessionDialog(BuildContext context, WidgetRef ref, Session session) async {
    final titleController = TextEditingController(text: session.title);
    final locationController = TextEditingController(text: session.location ?? '');
    var startDate = session.startTime;
    var startTime = TimeOfDay.fromDateTime(session.startTime);
    var endDate = session.endTime;
    var endTime = TimeOfDay.fromDateTime(session.endTime);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Sesi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nama Sesi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                const SizedBox(height: 8),
                _DatePickerField(
                  label: 'Tanggal Mulai',
                  value: startDate,
                  onPicked: (d) => setDialogState(() => startDate = d),
                ),
                const SizedBox(height: 8),
                _TimePickerField(
                  label: 'Jam Mulai',
                  value: startTime,
                  onPicked: (t) => setDialogState(() => startTime = t),
                ),
                const SizedBox(height: 8),
                _DatePickerField(
                  label: 'Tanggal Selesai',
                  value: endDate,
                  onPicked: (d) => setDialogState(() => endDate = d),
                ),
                const SizedBox(height: 8),
                _TimePickerField(
                  label: 'Jam Selesai',
                  value: endTime,
                  onPicked: (t) => setDialogState(() => endTime = t),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                Navigator.pop(ctx);
                await ref
                    .read(updateSessionControllerProvider.notifier)
                    .updateSession(
                      session.id,
                      UpdateSessionParams(
                        id: session.id,
                        title: titleController.text.trim(),
                        startTime: startDate,
                        endTime: endDate,
                        location: locationController.text.trim().isEmpty
                            ? null
                            : locationController.text.trim(),
                      ),
                    );
                ref.invalidate(eventDetailControllerProvider(event.id));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSession(BuildContext context, WidgetRef ref, Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Sesi'),
        content: Text('Hapus "${session.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deleteSessionControllerProvider.notifier).deleteSession(session.id);
      ref.invalidate(eventDetailControllerProvider(event.id));
    }
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateStr = '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}';
    final timeStr =
        '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')} - '
        '${session.endTime.hour.toString().padLeft(2, '0')}:${session.endTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesi ${session.order}: ${session.title}',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr, $timeStr',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (session.location != null)
                  Text(
                    session.location!,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (canManage) ...[
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  const _DatePickerField({required this.label, required this.value, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value != null ? '${value!.day}/${value!.month}/${value!.year}' : 'Pilih tanggal',
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPicked;

  const _TimePickerField({required this.label, required this.value, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value != null
              ? '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
              : 'Pilih jam',
        ),
      ),
    );
  }
}
