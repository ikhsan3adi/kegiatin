import 'package:flutter/material.dart';
import 'package:kegiatin/core/constants/api_constants.dart';

import 'package:cached_network_image/cached_network_image.dart';

class FullscreenImagePage extends StatelessWidget {
  const FullscreenImagePage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          child: CachedNetworkImage(
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
