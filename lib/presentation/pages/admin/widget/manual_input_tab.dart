import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/constants/api_constants.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/core/utils/string_utils.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/presentation/controllers/attendance/attendance_list_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/scan_attendance_controller.dart';
import 'package:kegiatin/presentation/controllers/rsvp/event_rsvp_list_controller.dart';

/// Tab input manual untuk mencatat kehadiran peserta terdaftar tanpa scan QR.
///
/// Admin dapat mencari peserta yang telah melakukan RSVP untuk kegiatan terpilih,
/// lalu menandai mereka hadir secara manual (mendukung sinkronisasi offline).
class ManualInputTab extends ConsumerStatefulWidget {
  final String? eventId;
  final String? sessionId;

  const ManualInputTab({super.key, this.eventId, this.sessionId});

  @override
  ConsumerState<ManualInputTab> createState() => _ManualInputTabState();
}

class _ManualInputTabState extends ConsumerState<ManualInputTab> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Listen status presensi manual dari ScanAttendanceController
    ref.listen<AsyncValue<Attendance?>>(scanAttendanceControllerProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: KegiatinCustomTheme.onGradient, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(next.error.toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: KegiatinCustomTheme.onGradient, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Presensi berhasil dicatat secara manual!', maxLines: 1)),
              ],
            ),
            backgroundColor: KegiatinCustomTheme.snackbarSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        ref.invalidate(attendanceListControllerProvider(widget.sessionId!));
      }
    });

    if (widget.eventId == null || widget.sessionId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note_outlined, size: 48, color: colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Text(
              'Silakan pilih kegiatan dan sesi terlebih dahulu',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final rsvpsAsync = ref.watch(eventRsvpListControllerProvider(widget.eventId!, search: _query));
    final attendancesAsync = ref.watch(attendanceListControllerProvider(widget.sessionId!));
    final scanState = ref.watch(scanAttendanceControllerProvider);
    final isLoadingScan = scanState.isLoading;

    return Stack(
      children: [
        Column(
          children: [
            // Input Pencarian
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    setState(() => _query = v.trim());
                  });
                },
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Cari Nama Anggota / NPA',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Daftar Peserta
            Expanded(
              child: rsvpsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat daftar RSVP: $err',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (rsvpResult) {
                  return attendancesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat daftar kehadiran: $err',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    data: (attendances) {
                      final rsvps = rsvpResult.data;

                      if (rsvps.isEmpty) {
                        final isEmptyState = _query.isEmpty;
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isEmptyState
                                    ? Icons.group_add_outlined
                                    : Icons.person_search_outlined,
                                size: 48,
                                color: colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isEmptyState
                                    ? 'Belum ada peserta terdaftar (RSVP)'
                                    : 'Peserta tidak ditemukan',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              'Peserta Terdaftar: ${rsvps.length}',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                              itemCount: rsvps.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final rsvp = rsvps[i];
                                final isPresent = attendances.any(
                                  (att) => att.userId == rsvp.userId,
                                );

                                return _PesertaCard(
                                  name: rsvp.user.displayName,
                                  initials: StringUtils.initials(rsvp.user.displayName),
                                  photoUrl: rsvp.user.photoUrl,
                                  isAnggota: rsvp.user.npa != null,
                                  npa: rsvp.user.npa,
                                  isPresent: isPresent,
                                  onHadir: () {
                                    ref
                                        .read(scanAttendanceControllerProvider.notifier)
                                        .scan(rsvp.qrToken, widget.sessionId!);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        // Overlay Loading saat memproses presensi manual
        if (isLoadingScan)
          Container(
            color: colorScheme.scrim.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

/// Card item detail peserta terdaftar beserta aksi presensi manual.
class _PesertaCard extends StatelessWidget {
  const _PesertaCard({
    required this.name,
    required this.initials,
    this.photoUrl,
    required this.isAnggota,
    this.npa,
    required this.isPresent,
    required this.onHadir,
  });

  final String name;
  final String initials;
  final String? photoUrl;
  final bool isAnggota;
  final String? npa;
  final bool isPresent;
  final VoidCallback onHadir;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPresent
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPresent
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar inisial
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                ? NetworkImage(ApiConstants.resolveImageUrl(photoUrl!))
                : null,
            child: photoUrl == null || photoUrl!.isEmpty
                ? Text(
                    initials,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Nama & keterangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  isAnggota
                      ? (npa != null && npa!.isNotEmpty ? 'NPA $npa' : 'Anggota')
                      : 'Non-Anggota',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Status hadir / tombol hadir
          if (isPresent)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Hadir',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            OutlinedButton(
              onPressed: onHadir,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: const Text('Hadir'),
            ),
        ],
      ),
    );
  }
}
