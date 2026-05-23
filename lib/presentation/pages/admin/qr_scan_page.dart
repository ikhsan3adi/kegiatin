import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/session.dart';
import 'package:kegiatin/presentation/controllers/attendance/attendance_list_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/scan_attendance_controller.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/pages/admin/widget/manual_input_tab.dart';
import 'package:kegiatin/presentation/pages/admin/widget/qr_scanner_tab.dart';

/// Halaman Pindai QR Presensi untuk Admin.
class QrScanPage extends ConsumerStatefulWidget {
  const QrScanPage({super.key});

  @override
  ConsumerState<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends ConsumerState<QrScanPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Kegiatan yang dipilih admin di dropdown.
  Event? _selectedEvent;

  /// Sesi yang dipilih admin di dropdown.
  Session? _selectedSession;
  int _totalScanned = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onQrDetected(String value) {
    if (_selectedSession == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: KegiatinCustomTheme.onGradient, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Pilih kegiatan dan sesi terlebih dahulu', maxLines: 1)),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      return;
    }
    setState(() => _totalScanned++);
    ref.read(scanAttendanceControllerProvider.notifier).scan(value, _selectedSession!.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<Attendance?>>(scanAttendanceControllerProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).clearSnackBars();
        final error = next.error;
        String message = 'Terjadi kesalahan';
        if (error is Failure) {
          message = error.message;
        } else {
          message = error.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: KegiatinCustomTheme.onGradient, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      } else if (next is AsyncData && next.value != null && _selectedSession != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: KegiatinCustomTheme.onGradient, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Presensi berhasil dicatat!', maxLines: 1)),
              ],
            ),
            backgroundColor: KegiatinCustomTheme.snackbarSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        ref.invalidate(attendanceListControllerProvider(_selectedSession!.id));
      }
    });
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Header melengkung
          _ScanHeader(
            selectedEvent: _selectedEvent,
            selectedSession: _selectedSession,
            totalScanned: _totalScanned,
            onEventChanged: (event) {
              setState(() {
                _selectedEvent = event;
                if (event != null && event.sessions.isNotEmpty) {
                  _selectedSession = event.sessions.first;
                } else {
                  _selectedSession = null;
                }
              });
            },
            onSessionChanged: (session) => setState(() => _selectedSession = session),
            onBack: () => Navigator.of(context).pop(),
          ),

          // TabBar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: textTheme.labelLarge,
              tabs: const [
                Tab(text: 'Pindai QR'),
                Tab(text: 'Input Manual'),
              ],
            ),
          ),

          // Konten Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                QrScannerTab(onDetect: _onQrDetected),
                ManualInputTab(eventId: _selectedEvent?.id, sessionId: _selectedSession?.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Header
class _ScanHeader extends StatelessWidget {
  const _ScanHeader({
    required this.selectedEvent,
    required this.selectedSession,
    required this.totalScanned,
    required this.onEventChanged,
    required this.onSessionChanged,
    required this.onBack,
  });

  final Event? selectedEvent;
  final Session? selectedSession;
  final int totalScanned;
  final ValueChanged<Event?> onEventChanged;
  final ValueChanged<Session?> onSessionChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [KegiatinCustomTheme.appBarTop, KegiatinCustomTheme.appBarBottom],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol kembali + Judul
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: KegiatinCustomTheme.onGradient,
                    tooltip: 'Kembali',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pindai QR Presensi',
                        style: textTheme.titleMedium?.copyWith(
                          color: KegiatinCustomTheme.onGradient,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$totalScanned sudah dipindai',
                        style: textTheme.bodySmall?.copyWith(
                          color: KegiatinCustomTheme.onGradientDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dropdown kegiatan aktif dari database dengan pencarian bottom sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _EventDropdown(selected: selectedEvent, onChanged: onEventChanged),
              ),

              // Dropdown sesi kegiatan jika ada kegiatan terpilih dan memiliki sesi
              if (selectedEvent != null && selectedEvent!.sessions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _SessionDropdown(
                    sessions: selectedEvent!.sessions,
                    selected: selectedSession,
                    onChanged: onSessionChanged,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown pemilih kegiatan dari database menggunakan Bottom Sheet.
class _EventDropdown extends ConsumerWidget {
  const _EventDropdown({required this.selected, required this.onChanged});

  final Event? selected;
  final ValueChanged<Event?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _showSearchBottomSheet(context, ref),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: KegiatinCustomTheme.glassInput,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KegiatinCustomTheme.glassInputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_note_outlined,
              size: 16,
              color: KegiatinCustomTheme.onGradientSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected?.title ?? 'Pilih Kegiatan',
                style: textTheme.bodyMedium?.copyWith(
                  color: selected != null
                      ? KegiatinCustomTheme.onGradient
                      : KegiatinCustomTheme.onGradientSecondary,
                  fontWeight: selected != null ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: KegiatinCustomTheme.onGradient),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventSearchBottomSheet(onSelected: onChanged),
    );
  }
}

class _EventSearchBottomSheet extends ConsumerStatefulWidget {
  const _EventSearchBottomSheet({required this.onSelected});

  final ValueChanged<Event?> onSelected;

  @override
  ConsumerState<_EventSearchBottomSheet> createState() => _EventSearchBottomSheetState();
}

class _EventSearchBottomSheetState extends ConsumerState<_EventSearchBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final eventsState = ref.watch(
      eventListControllerProvider(limit: 20, search: _searchQuery.isEmpty ? null : _searchQuery),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Cari Kegiatan',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama kegiatan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: eventsState.when(
                  data: (paginated) {
                    final events = paginated.data;
                    if (events.isEmpty) {
                      return const Center(child: Text('Kegiatan tidak ditemukan'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.location),
                          leading: const Icon(Icons.event),
                          onTap: () {
                            widget.onSelected(event);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dropdown pemilih sesi dari kegiatan terpilih.
class _SessionDropdown extends StatelessWidget {
  const _SessionDropdown({required this.sessions, required this.selected, required this.onChanged});

  final List<Session> sessions;
  final Session? selected;
  final ValueChanged<Session?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Pastikan nilai selected masih ada di list sessions
    final validSelected = sessions.any((s) => s.id == selected?.id) ? selected : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: KegiatinCustomTheme.glassInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KegiatinCustomTheme.glassInputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Session>(
          value: validSelected,
          dropdownColor: KegiatinCustomTheme.appBarTop,
          iconEnabledColor: KegiatinCustomTheme.onGradient,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: textTheme.bodyMedium?.copyWith(color: KegiatinCustomTheme.onGradient),
          items: sessions
              .map(
                (s) => DropdownMenuItem<Session>(
                  value: s,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: KegiatinCustomTheme.onGradientSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.title,
                          style: textTheme.bodyMedium?.copyWith(
                            color: KegiatinCustomTheme.onGradient,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          hint: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: KegiatinCustomTheme.onGradientSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pilih Sesi',
                style: textTheme.bodyMedium?.copyWith(
                  color: KegiatinCustomTheme.onGradientSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
