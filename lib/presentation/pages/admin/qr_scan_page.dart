import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
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
    setState(() => _totalScanned++);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('QR terbaca: $value', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Watch event list — ambil semua (limit tinggi) tanpa filter agar dropdown lengkap
    final eventsAsync = ref.watch(eventListControllerProvider(limit: 100));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Header melengkung
          _ScanHeader(
            eventsAsync: eventsAsync,
            selectedEvent: _selectedEvent,
            totalScanned: _totalScanned,
            onEventChanged: (event) => setState(() => _selectedEvent = event),
            onBack: () => Navigator.of(context).pop(),
            onRetry: () => ref.invalidate(eventListControllerProvider(limit: 100)),
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
                const ManualInputTab(),
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
    required this.eventsAsync,
    required this.selectedEvent,
    required this.totalScanned,
    required this.onEventChanged,
    required this.onBack,
    required this.onRetry,
  });

  final AsyncValue<PaginatedResult<Event>> eventsAsync;
  final Event? selectedEvent;
  final int totalScanned;
  final ValueChanged<Event?> onEventChanged;
  final VoidCallback onBack;
  final VoidCallback onRetry;

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
                    color: Colors.white,
                    tooltip: 'Kembali',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pindai QR Presensi',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$totalScanned sudah dipindai',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dropdown kegiatan aktif dari database
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _EventDropdown(
                  eventsAsync: eventsAsync,
                  selected: selectedEvent,
                  onChanged: onEventChanged,
                  onRetry: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown pemilih kegiatan dari database dengan state loading/error/data.
class _EventDropdown extends StatelessWidget {
  const _EventDropdown({
    required this.eventsAsync,
    required this.selected,
    required this.onChanged,
    required this.onRetry,
  });

  final AsyncValue<PaginatedResult<Event>> eventsAsync;
  final Event? selected;
  final ValueChanged<Event?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: eventsAsync.when(
        loading: () => _buildLoadingState(textTheme),
        error: (_, _) => _buildErrorState(textTheme),
        data: (result) {
          final events = result.data;
          return _buildDropdown(context, textTheme, events);
        },
      ),
    );
  }

  Widget _buildLoadingState(TextTheme textTheme) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const Icon(Icons.event_note_outlined, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text('Memuat kegiatan...', style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          const Spacer(),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TextTheme textTheme) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gagal memuat kegiatan',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Text('Coba lagi', style: textTheme.labelSmall?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, TextTheme textTheme, List<Event> events) {
    if (events.isEmpty) {
      return SizedBox(
        height: 40,
        child: Row(
          children: [
            const Icon(Icons.event_busy_outlined, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              'Belum ada kegiatan tersedia',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    // Pastikan nilai selected masih valid setelah data dimuat
    final validSelected = events.any((e) => e.id == selected?.id) ? selected : null;

    return DropdownButtonHideUnderline(
      child: DropdownButton<Event>(
        value: validSelected,
        dropdownColor: KegiatinCustomTheme.appBarTop,
        iconEnabledColor: Colors.white,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: textTheme.bodyMedium?.copyWith(color: Colors.white),
        items: events
            .map(
              (e) => DropdownMenuItem<Event>(
                value: e,
                child: Row(
                  children: [
                    const Icon(Icons.event_note_outlined, size: 16, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.title,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
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
            const Icon(Icons.event_note_outlined, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text('Pilih Kegiatan', style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
