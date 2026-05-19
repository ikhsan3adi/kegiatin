import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';

class UploadMateriBottomSheet extends ConsumerStatefulWidget {
  const UploadMateriBottomSheet({super.key});

  @override
  ConsumerState<UploadMateriBottomSheet> createState() => _UploadMateriBottomSheetState();
}

class _UploadMateriBottomSheetState extends ConsumerState<UploadMateriBottomSheet> {
  // UI-only local state
  String _selectedType = 'PDF'; // 'PDF' | 'LINK'
  Event? _selectedEvent;
  Session? _selectedSession;
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  List<Session> get _availableSessions => _selectedEvent?.sessions ?? [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Fetch semua event (tanpa filter) untuk pilihan dropdown
    final eventsState = ref.watch(eventListControllerProvider());

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Handle bar ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unggah Materi',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Pilih Kegiatan ───────────────────────────────────────────
            eventsState.when(
              data: (paginated) {
                final events = paginated.data;
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Pilih Kegiatan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  child: DropdownButton<Event>(
                    value: _selectedEvent,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('Pilih kegiatan'),
                    items: events
                        .map(
                          (e) => DropdownMenuItem<Event>(
                            value: e,
                            child: Text(e.title, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedEvent = val;
                        // Auto-select session jika hanya ada 1 (misal Single Event)
                        if (val != null && val.sessions.length == 1) {
                          _selectedSession = val.sessions.first;
                        } else {
                          _selectedSession = null;
                        }
                      });
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                'Gagal memuat kegiatan',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
            const SizedBox(height: 16),

            if (_availableSessions.length > 1) ...[
              // ── Pilih Sesi ───────────────────────────────────────────────
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Pilih Sesi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: DropdownButton<Session>(
                  value: _selectedSession,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Text(
                    _selectedEvent == null ? 'Pilih kegiatan terlebih dahulu' : 'Pilih sesi',
                  ),
                  // Nonaktif jika belum ada kegiatan atau tidak ada sesi
                  onChanged: (_availableSessions.isEmpty)
                      ? null
                      : (val) => setState(() => _selectedSession = val),
                  items: _availableSessions
                      .map(
                        (s) => DropdownMenuItem<Session>(
                          value: s,
                          child: Text(s.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Judul Materi ─────────────────────────────────────────────
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Materi',
                hintText: 'Masukkan judul materi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // ── Toggle Tipe Materi ───────────────────────────────────────
            Text('Tipe Materi', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'PDF',
                  label: Text('Dokumen (PDF)'),
                  icon: Icon(Icons.picture_as_pdf_rounded),
                ),
                ButtonSegment(
                  value: 'LINK',
                  label: Text('Tautan (Link)'),
                  icon: Icon(Icons.link_rounded),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedType = newSelection.first);
              },
            ),
            const SizedBox(height: 16),

            // ── Input bergantung tipe ────────────────────────────────────
            if (_selectedType == 'PDF')
              InkWell(
                onTap: () {
                  // TODO: Sambungkan file picker (misalnya file_picker package)
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_file_rounded, size: 48, color: colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk memilih file PDF',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              TextField(
                controller: _linkController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL Tautan',
                  hintText: 'https://',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
            const SizedBox(height: 32),

            // ── Tombol Simpan ────────────────────────────────────────────
            FilledButton(
              onPressed: () {
                // TODO: Kirim data materi ke repository
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Unggah Materi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
