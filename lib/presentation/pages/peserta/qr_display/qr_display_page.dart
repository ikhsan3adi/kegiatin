import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_detail_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/my_rsvp_controller.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PesertaQrDisplayPage extends ConsumerWidget {
  const PesertaQrDisplayPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final asyncEvent = ref.watch(eventDetailControllerProvider(eventId));
    final myRsvps = ref.watch(myRsvpControllerProvider);
    final asyncUser = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildGradientHeader(context, textTheme),
          Expanded(
            child: myRsvps.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat RSVP: $e')),
              data: (rsvps) {
                final rsvp = rsvps.where((r) => r.eventId == eventId).firstOrNull;
                if (rsvp == null) {
                  return _buildNoRsvp(colorScheme, textTheme);
                }
                final user = asyncUser.whenOrNull(data: (u) => u);
                return asyncEvent.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      _buildQrContent(context, rsvp, null, user, colorScheme, textTheme),
                  data: (event) =>
                      _buildQrContent(context, rsvp, event, user, colorScheme, textTheme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    return KegiatinAppBar(
      height: null,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 20),
      child: Row(
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
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code Saya',
                style: textTheme.headlineMedium?.copyWith(color: KegiatinCustomTheme.onGradient),
              ),
              Text(
                'Tunjukkan QR ini kepada admin untuk presensi',
                style: textTheme.bodyMedium?.copyWith(
                  color: KegiatinCustomTheme.onGradientSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoRsvp(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_outlined, size: 80, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Belum Terdaftar',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda belum mendaftar ke kegiatan ini',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContent(
    BuildContext context,
    Rsvp rsvp,
    Event? event,
    User? user,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _buildQrCard(rsvp, event, user, colorScheme, textTheme),
          const SizedBox(height: 20),
          _buildWarningLabel(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildQrCard(
    Rsvp rsvp,
    Event? event,
    User? user,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(colorScheme, textTheme),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (user != null) _buildUserInfo(user, colorScheme, textTheme),
                if (user != null) const SizedBox(height: 24),
                if (event != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event_seat_rounded, color: colorScheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.title,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.location,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (event.sessions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Text(
                            event.sessions.length == 1
                                ? 'Jadwal Sesi:'
                                : 'Jadwal Sesi (${event.sessions.length}):',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...event.sessions.map((session) {
                            final sessionTime =
                                '${session.startTime.toLocal().day.toString().padLeft(2, '0')}/${session.startTime.toLocal().month.toString().padLeft(2, '0')} - '
                                '${session.startTime.toLocal().hour.toString().padLeft(2, '0')}:${session.startTime.toLocal().minute.toString().padLeft(2, '0')}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time, color: colorScheme.primary, size: 12),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${session.title}: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: sessionTime,
                                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // QR code — centered, white background required for scanner
                Center(
                  child: QrImageView(
                    data: rsvp.qrToken,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: KegiatinCustomTheme.appBarTop,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: KegiatinCustomTheme.appBarTop,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildQrCode(rsvp, colorScheme, textTheme),
                const SizedBox(height: 16),
                _buildQrMeta(rsvp, colorScheme, textTheme),
              ],
            ),
          ),
          _buildCardFooter(rsvp, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildCardHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KegiatinCustomTheme.appBarTop, KegiatinCustomTheme.appBarBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PEMUDA PERSATUAN ISLAM',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Kartu QR Presensi',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user, ColorScheme colorScheme, TextTheme textTheme) {
    final initials = _initials(user.displayName);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary),
          clipBehavior: Clip.antiAlias,
          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: ApiConstants.resolveImageUrl(user.photoUrl!),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Text(
                      initials,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      initials,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.displayName,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (user.npa != null)
              Text(
                'NPA ${user.npa}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrCode(Rsvp rsvp, ColorScheme colorScheme, TextTheme textTheme) {
    // Shorten qrToken for display: show last 12 chars prefixed with ellipsis
    // final displayCode = rsvp.qrToken.length > 16
    //     ? '…${rsvp.qrToken.substring(rsvp.qrToken.length - 12)}'
    //     : rsvp.qrToken;
    return Text(
      rsvp.qrToken,
      textAlign: TextAlign.center,
      style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
    );
  }

  Widget _buildQrMeta(Rsvp rsvp, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Tunjukkan QR ini ke panitia untuk presensi',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFooter(Rsvp rsvp, ColorScheme colorScheme, TextTheme textTheme) {
    final createdAtLocal = rsvp.createdAt.toLocal();
    final dateStr =
        '${createdAtLocal.day.toString().padLeft(2, '0')}.'
        '${createdAtLocal.month.toString().padLeft(2, '0')}.'
        '${createdAtLocal.year.toString().substring(2)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Text(
        'Digenerate: $dateStr',
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildWarningLabel(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: colorScheme.error),
        const SizedBox(width: 6),
        Text(
          'Jangan bagikan Kode QR ini!',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
