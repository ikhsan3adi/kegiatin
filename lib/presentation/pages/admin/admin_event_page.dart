import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/controllers/event/event_list_controller.dart';
import 'package:kegiatin/presentation/widgets/event_list_card.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';

class AdminEventPage extends ConsumerStatefulWidget {
  const AdminEventPage({super.key});

  @override
  ConsumerState<AdminEventPage> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends ConsumerState<AdminEventPage> {
  String? _selectedStatus;
  String _searchQuery = '';
  final _searchController = TextEditingController();
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
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  Widget _buildFilterChip(String label, String? statusValue, ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = _selectedStatus == statusValue;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              _selectedStatus = statusValue;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Fetch events with filters
    final eventsState = ref.watch(eventListControllerProvider(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      status: _selectedStatus,
    ));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(eventListControllerProvider(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          status: _selectedStatus,
        ));
        try {
          await ref.read(eventListControllerProvider(
            search: _searchQuery.isEmpty ? null : _searchQuery,
            status: _selectedStatus,
          ).future);
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KegiatinAppBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kegiatan',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  eventsState.maybeWhen(
                    data: (paginatedData) => Text(
                      '${paginatedData.data.length} Kegiatan Tersedia',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    orElse: () => Text(
                      'Memuat kegiatan...',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Cari Kegiatan...',
                      hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterChip('Semua', null, colorScheme, textTheme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Berlangsung', 'ONGOING', colorScheme, textTheme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Akan Datang', 'PUBLISHED', colorScheme, textTheme),
                    ],
                  ),
                ),
              ),
            ),

            eventsState.when(
              data: (paginatedData) {
                final events = paginatedData.data;

                if (events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada kegiatan',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventListCard(
                      event: event,
                      showActionButton: false,
                      onTap: () => context.push('/admin/event-detail/${event.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Gagal memuat kegiatan: $e'),
                ),
              ),
            ),
            const SizedBox(height: 80), // Padding bawah agar tidak tertutup navbar
          ],
        ),
      ),
    );
  }
}
