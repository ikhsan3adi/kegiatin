import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminEventDetailHeader extends StatelessWidget {
  const AdminEventDetailHeader({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final firstSession = event.sessions.isNotEmpty ? event.sessions.first : null;
    final startTime = firstSession?.startTime;
    final dateStr = startTime != null
        ? "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')} . ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"
        : 'Waktu belum ditentukan';

    final hasBanner = event.imageUrl != null && event.imageUrl!.isNotEmpty;

    if (hasBanner) {
      return Container(
        height: 250,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.network(
              event.imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: colorScheme.primary,
                child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.black87],
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _Badge(
                          text: _statusLabel(event.status),
                          backgroundColor: Colors.white24,
                          textColor: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          text: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                          backgroundColor: Colors.white24,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(dateStr, style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return KegiatinAppBar(
      height: null,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(
                text: _statusLabel(event.status),
                backgroundColor: colorScheme.secondaryContainer,
                textColor: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              _Badge(
                text: event.type == EventType.series ? 'Rutin' : 'Tunggal',
                backgroundColor: colorScheme.tertiaryContainer,
                textColor: colorScheme.onTertiaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _statusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Akan Datang';
      case EventStatus.ongoing:
        return 'Berlangsung';
      case EventStatus.completed:
        return 'Selesai';
      case EventStatus.cancelled:
        return 'Batal';
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.backgroundColor, required this.textColor});

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        style: textTheme.labelSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
