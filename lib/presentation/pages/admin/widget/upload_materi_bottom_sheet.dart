import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/utils/pdf_generator.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/controllers/archive/upload_materi_controller.dart';
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
  final List<ProcessedImage> _capturedImages = [];

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
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'webp',
          'zip',
        ],
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

    String? finalFilePath;

    if (_selectedType == 'FILE') {
      if (_scannedFile == null) {
        unawaited(
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Lengkapi Data'),
              content: Text('Silakan pilih file atau scan dokumen terlebih dahulu.'),
            ),
          ),
        );
        return;
      }
      finalFilePath = _scannedFile!.filePath;
    } else if (_selectedType == 'MULTI_IMAGE') {
      if (_capturedImages.isEmpty) {
        unawaited(
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Lengkapi Data'),
              content: Text(
                'Silakan ambil minimal 1 foto menggunakan Smart Camera terlebih dahulu.',
              ),
            ),
          ),
        );
        return;
      }

      // Tampilkan dialog progress pembuatan PDF agar sangat interaktif
      if (mounted) {
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menyusun PDF dari foto...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      try {
        finalFilePath = await PdfGenerator.imagesToPdf(
          _capturedImages.map((img) => img.filePath).toList(),
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Pop dialog progress
          unawaited(
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Gagal PDF'),
                content: Text('Terjadi kesalahan menyusun PDF: $e'),
              ),
            ),
          );
        }
        return;
      }
      if (mounted) Navigator.pop(context); // Pop dialog progress
    } else if (_selectedType == 'LINK') {
      if (_linkController.text.trim().isEmpty) {
        unawaited(
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Lengkapi Data'),
              content: Text('Masukkan URL tautan materi.'),
            ),
          ),
        );
        return;
      }
    }

    final uploadCtrl = ref.read(uploadMateriControllerProvider.notifier);
    await uploadCtrl.upload(
      UploadMateriArgs(
        sessionId: _selectedSession!.id,
        title: _titleController.text.trim(),
        type: ArchiveType.material,
        filePath: finalFilePath,
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
                          child: Text(
                            s.title,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge,
                          ),
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
                  label: Text('File'),
                  icon: Icon(Icons.file_copy_outlined),
                ),
                ButtonSegment(
                  value: 'MULTI_IMAGE',
                  label: Text('Gambar PDF'),
                  icon: Icon(Icons.picture_as_pdf_outlined),
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
                Builder(
                  builder: (context) {
                    final path = _scannedFile!.filePath;
                    final ext = path.split('.').last.toLowerCase();
                    final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(ext);

                    if (isImage) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(path), height: 160, fit: BoxFit.cover),
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              size: 36,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    path.split('/').last,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(_scannedFile!.fileSize / 1024).toStringAsFixed(1)} KB',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ukuran: ${(_scannedFile!.fileSize / 1024).toStringAsFixed(1)} KB',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _scannedFile!.isDocumentScan
                          ? _handleScanDocument
                          : _handlePickFile,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(_scannedFile!.isDocumentScan ? 'Scan Ulang' : 'Pilih File Lain'),
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
            ] else if (_selectedType == 'MULTI_IMAGE') ...[
              if (_capturedImages.isNotEmpty) ...[
                Text(
                  'Daftar Foto (${_capturedImages.length}):',
                  style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _capturedImages.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final img = _capturedImages[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(
                                File(img.filePath),
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: colorScheme.error.withValues(alpha: 0.9),
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: () => setState(() => _capturedImages.removeAt(index)),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(Icons.close, size: 14, color: colorScheme.onError),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: () async {
                  final result = await launchSmartCamera(context, ref, mode: CameraMode.document);
                  if (result != null && mounted) {
                    setState(() => _capturedImages.add(result));
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_a_photo_rounded, size: 38, color: colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Ambil Foto via Smart Camera',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ambil gambar materi secara berurutan untuk dijadikan PDF',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
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
