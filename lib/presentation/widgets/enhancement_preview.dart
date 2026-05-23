import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/pcd/image_enhancer.dart';

class EnhancementPreview extends StatefulWidget {
  const EnhancementPreview({super.key, required this.imageBytes, this.defaultMode});

  final Uint8List imageBytes;
  final EnhancementMode? defaultMode;

  static Future<EnhancementMode?> show(
    BuildContext context, {
    required Uint8List imageBytes,
    EnhancementMode defaultMode = EnhancementMode.enhanced,
  }) {
    return showModalBottomSheet<EnhancementMode>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EnhancementPreview(imageBytes: imageBytes, defaultMode: defaultMode),
    );
  }

  @override
  State<EnhancementPreview> createState() => _EnhancementPreviewState();
}

class _EnhancementPreviewState extends State<EnhancementPreview> {
  late EnhancementMode _selectedMode;
  Uint8List? _previewBytes;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.defaultMode ?? EnhancementMode.enhanced;
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    setState(() => _processing = true);

    final result = await ImageEnhancer.enhance(widget.imageBytes, _selectedMode);

    if (mounted) {
      setState(() {
        _previewBytes = result;
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  'Preview Hasil Scan',
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

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _previewBytes != null
                      ? Image.memory(_previewBytes!, fit: BoxFit.contain)
                      : Container(
                          height: 200,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                  if (_processing)
                    Container(
                      height: 200,
                      color: colorScheme.scrim.withValues(alpha: 0.26),
                      child: const CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Mode', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<EnhancementMode>(
              segments: const [
                ButtonSegment(
                  value: EnhancementMode.original,
                  label: Text('Asli'),
                  icon: Icon(Icons.image_outlined),
                ),
                ButtonSegment(
                  value: EnhancementMode.enhanced,
                  label: Text('Ditingkatkan'),
                  icon: Icon(Icons.auto_awesome_outlined),
                ),
                ButtonSegment(
                  value: EnhancementMode.grayscaleEnhanced,
                  label: Text('Grayscale'),
                  icon: Icon(Icons.filter_b_and_w_outlined),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedMode = newSelection.first);
                _generatePreview();
              },
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _processing ? null : () => Navigator.pop(context, _selectedMode),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Gunakan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
