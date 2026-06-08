import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kegiatin/core/constants/api_constants.dart';

import 'package:cached_network_image/cached_network_image.dart';

class FullscreenImagePage extends StatelessWidget {
  const FullscreenImagePage({super.key, required this.imageUrl, this.localFilePath});

  final String imageUrl;
  final String? localFilePath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasLocal = localFilePath != null && File(localFilePath!).existsSync();

    return Scaffold(
      backgroundColor: colorScheme.scrim,
      appBar: AppBar(
        backgroundColor: colorScheme.scrim,
        iconTheme: IconThemeData(color: colorScheme.onInverseSurface),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: hasLocal
              ? Image.file(
                  File(localFilePath!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: colorScheme.onInverseSurface, size: 64),
                )
              : CachedNetworkImage(
                  imageUrl: ApiConstants.resolveImageUrl(imageUrl),
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.broken_image, color: colorScheme.onInverseSurface, size: 64),
                ),
        ),
      ),
    );
  }
}
