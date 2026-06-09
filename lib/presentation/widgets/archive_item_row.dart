import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/utils/snackbar_helper.dart';
import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/presentation/controllers/archive/session_archives_controller.dart';
import 'package:kegiatin/presentation/pages/fullscreen_image_page.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

/// A shared widget to display an archive material item.
/// Supports downloading and opening local files for both admin and peserta views.
class ArchiveItemRow extends ConsumerStatefulWidget {
  const ArchiveItemRow({super.key, required this.archive, this.isAccessible = true, this.onDelete});

  final ArchiveItem archive;
  final bool isAccessible;
  final VoidCallback? onDelete;

  @override
  ConsumerState<ArchiveItemRow> createState() => _ArchiveItemRowState();
}

class _ArchiveItemRowState extends ConsumerState<ArchiveItemRow> {
  bool _isDownloading = false;

  Future<void> _openFile(String localFilePath, String fileUrl, bool isImg) async {
    if (isImg) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenImagePage(imageUrl: fileUrl, localFilePath: localFilePath),
        ),
      );
    } else {
      final openResult = await OpenFilex.open(localFilePath);
      if (openResult.type != ResultType.done) {
        if (mounted) {
          SnackBarHelper.showError(context, 'Gagal membuka file: ${openResult.message}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasLocal = widget.archive.localFilePath != null;
    final isDownloaded = hasLocal && File(widget.archive.localFilePath!).existsSync();
    final isImg = _isImageFile(widget.archive.fileUrl);
    final isLink = !_isDownloadableFile(widget.archive.fileUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: _isDownloading
            ? null
            : () async {
                if (!widget.isAccessible) {
                  SnackBarHelper.showWarning(
                    context,
                    'Akses materi hanya untuk peserta yang hadir/terlambat pada sesi ini',
                  );
                  return;
                }

                // Check if it's a web link
                final isLink = !_isDownloadableFile(widget.archive.fileUrl);
                if (isLink) {
                  final uri = Uri.parse(widget.archive.fileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      SnackBarHelper.showError(context, 'Tidak dapat membuka tautan ini');
                    }
                  }
                  return;
                }

                // Downloadable file flow
                if (isDownloaded) {
                  await _openFile(widget.archive.localFilePath!, widget.archive.fileUrl, isImg);
                } else {
                  final isOnline = await ref.read(networkInfoProvider).isConnected;
                  if (!isOnline) {
                    if (context.mounted) {
                      SnackBarHelper.showWarning(
                        context,
                        'Materi belum diunduh. Silakan hubungkan ke internet.',
                      );
                    }
                    return;
                  }

                  setState(() {
                    _isDownloading = true;
                  });

                  try {
                    final updatedItem = await ref
                        .read(sessionArchivesControllerProvider(widget.archive.sessionId).notifier)
                        .downloadArchive(widget.archive);

                    // Once download succeeds, open it immediately without showing a success popup
                    if (updatedItem.localFilePath != null &&
                        File(updatedItem.localFilePath!).existsSync()) {
                      await _openFile(updatedItem.localFilePath!, updatedItem.fileUrl, isImg);
                    } else {
                      throw Exception('File path tidak ditemukan setelah unduhan.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackBarHelper.showError(context, 'Gagal mengunduh materi: $e');
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isDownloading = false;
                      });
                    }
                  }
                }
              },
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: widget.isAccessible ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                if (widget.isAccessible)
                  _buildMaterialThumbnail(
                    context,
                    widget.archive.fileUrl,
                    localFilePath: widget.archive.localFilePath,
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.archive.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: widget.isAccessible ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isAccessible) ...[
                  if (isLink)
                    Icon(Icons.open_in_new, size: 20, color: colorScheme.primary)
                  else if (_isDownloading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (isDownloaded)
                    Icon(
                      isImg ? Icons.photo_outlined : Icons.download_done,
                      size: 20,
                      color: colorScheme.primary,
                    )
                  else
                    Icon(Icons.download_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                ],
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 16, color: colorScheme.error),
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onDelete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getFileExtension(String url) {
  try {
    final path = Uri.parse(url).path;
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex != -1) {
      return path.substring(dotIndex + 1).toLowerCase();
    }
  } catch (_) {}
  return '';
}

bool _isImageFile(String url) {
  final ext = _getFileExtension(url);
  return ext == 'jpg' ||
      ext == 'jpeg' ||
      ext == 'png' ||
      ext == 'gif' ||
      ext == 'webp' ||
      ext == 'bmp';
}

Widget _buildMaterialThumbnail(BuildContext context, String fileUrl, {String? localFilePath}) {
  final colorScheme = Theme.of(context).colorScheme;
  if (_isImageFile(fileUrl)) {
    final hasLocal = localFilePath != null && File(localFilePath).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: hasLocal
          ? Image.file(
              File(localFilePath),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 40,
                height: 40,
                color: colorScheme.errorContainer,
                child: Icon(Icons.broken_image, size: 20, color: colorScheme.error),
              ),
            )
          : CachedNetworkImage(
              imageUrl: ApiConstants.resolveImageUrl(fileUrl),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                color: colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                color: colorScheme.errorContainer,
                child: Icon(Icons.broken_image, size: 20, color: colorScheme.error),
              ),
            ),
    );
  }

  final ext = _getFileExtension(fileUrl);
  IconData iconData = Icons.description_outlined;
  Color iconColor = colorScheme.primary;
  Color bgColor = colorScheme.primaryContainer.withValues(alpha: 0.3);

  if (ext == 'pdf') {
    iconData = Icons.picture_as_pdf_outlined;
    iconColor = colorScheme.error;
    bgColor = colorScheme.errorContainer.withValues(alpha: 0.3);
  } else if (ext == 'xlsx' || ext == 'xls' || ext == 'csv') {
    iconData = Icons.table_chart_outlined;
    iconColor = Colors.green;
    bgColor = Colors.green.withValues(alpha: 0.15);
  } else if (ext == 'docx' || ext == 'doc' || ext == 'txt') {
    iconData = Icons.article_outlined;
    iconColor = colorScheme.primary;
    bgColor = colorScheme.primaryContainer.withValues(alpha: 0.3);
  } else if (!_isDownloadableFile(fileUrl)) {
    iconData = Icons.link;
    iconColor = colorScheme.secondary;
    bgColor = colorScheme.secondaryContainer.withValues(alpha: 0.3);
  }

  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
    child: Icon(iconData, color: iconColor, size: 20),
  );
}

bool _isDownloadableFile(String url) {
  final ext = _getFileExtension(url);
  if (ext.isEmpty) return false;

  const fileExtensions = {
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'zip',
    'rar',
    'tar',
    'gz',
    'mp3',
    'mp4',
  };
  return fileExtensions.contains(ext);
}
