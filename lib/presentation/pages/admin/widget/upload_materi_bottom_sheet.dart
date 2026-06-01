import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/controllers/archive/upload_materi_controller.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/widgets/smart_camera_launcher.dart';

class UploadMateriBottomSheet extends ConsumerStatefulWidget {
  const UploadMateriBottomSheet({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<UploadMateriBottomSheet> createState() => _UploadMateriBottomSheetState();
}

class _UploadMateriBottomSheetState extends ConsumerState<UploadMateriBottomSheet> {
  String _selectedType = 'FILE';
  Session? _selectedSession;
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  ProcessedImage? _scannedFile;

  @override
  void initState() {
    super.initState();
    if (widget.event.type == EventType.single) {
      if (widget.event.sessions.isNotEmpty) {
        _selectedSession = widget.event.sessions.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  List<Session> get _availableSessions => widget.event.sessions;

  Future<void> _handleScanDocument() async {
    final result = await launchSmartCamera(context, ref, mode: CameraMode.document);
    if (result != null && mounted) {
      setState(() => _scannedFile = result);
    }
  }

  Future<void> _handlePickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null && result.files.single.path != null && mounted) {
        final path = result.files.single.path!;
        final file = File(path);
        final size = await file.length();

        setState(() {
          _scannedFile = ProcessedImage(
            filePath: path,
            enhancementMode: 'original',
            fileSize: size,
            isDocumentScan: false,
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedSession == null || _titleController.text.trim().isEmpty) {
      unawaited(
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Lengkapi Data'),
            content: Text('Pilih sesi dan masukkan judul materi.'),
          ),
        ),
      );
      return;
    }

    final uploadCtrl = ref.read(uploadMateriControllerProvider.notifier);
    await uploadCtrl.upload(
      UploadMateriArgs(
        sessionId: _selectedSession!.id,
        title: _titleController.text.trim(),
        type: ArchiveType.material,
        filePath: _scannedFile?.filePath,
        linkUrl: _selectedType == 'LINK' ? _linkController.text.trim() : null,
      ),
    );

    if (!mounted) return;
    await Future.microtask(() {});
    if (!mounted) return;
    final currentState = ref.read(uploadMateriControllerProvider);
    currentState.whenOrNull(
      error: (err, _) {
        unawaited(
          showDialog(
            context: context,
            builder: (_) => AlertDialog(title: const Text('Gagal'), content: Text('$err')),
          ),
        );
      },
      data: (_) {
        if (_selectedSession != null) {
          ref.invalidate(sessionArchivesControllerProvider(_selectedSession!.id));
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Materi berhasil diunggah')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final uploadState = ref.watch(uploadMateriControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (widget.event.type == EventType.series) ...[
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
                  hint: const Text('Pilih sesi'),
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
            Text('Tipe Materi', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'FILE',
                  label: Text('Dokumen'),
                  icon: Icon(Icons.file_copy_outlined),
                ),
                ButtonSegment(value: 'LINK', label: Text('Tautan'), icon: Icon(Icons.link_rounded)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedType = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedType == 'FILE') ...[
              if (_scannedFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_scannedFile!.filePath), height: 160, fit: BoxFit.cover),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mode: ${_scannedFile!.enhancementMode} · ${(_scannedFile!.fileSize / 1024).toStringAsFixed(1)} KB',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _handleScanDocument,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Scan Ulang'),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _handlePickFile,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.upload_file_rounded, size: 36, color: colorScheme.primary),
                              const SizedBox(height: 4),
                              Text(
                                'Pilih File',
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _handleScanDocument,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.document_scanner_rounded,
                                size: 36,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Scan Dokumen',
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ] else
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
            FilledButton(
              onPressed: uploadState.isLoading ? null : _handleUpload,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: uploadState.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Text(
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
