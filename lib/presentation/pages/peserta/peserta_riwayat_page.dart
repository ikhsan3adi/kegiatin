import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/usecases/get_history_usecase.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_activity_history_card.dart';
import 'package:kegiatin/presentation/providers/history_providers.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'peserta_riwayat_page.g.dart';

@Riverpod(keepAlive: true)
class HistoryController extends _$HistoryController {
  @override
  FutureOr<List<ActivityRecord>> build() async {
    final useCase = ref.read(getHistoryUseCaseProvider);
    final result = await useCase(const GetHistoryParams());
    return result.fold((failure) => throw Exception(failure.message), (data) => data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final useCase = ref.read(getHistoryUseCaseProvider);
    final result = await useCase(const GetHistoryParams(forceRefresh: true));
    state = result.fold(
      (failure) => AsyncError(Exception(failure.message), StackTrace.current),
      (data) => AsyncData(data),
    );
  }
}

class PesertaRiwayatPage extends ConsumerStatefulWidget {
  const PesertaRiwayatPage({super.key});

  @override
  ConsumerState<PesertaRiwayatPage> createState() => _PesertaRiwayatPageState();
}

class _PesertaRiwayatPageState extends ConsumerState<PesertaRiwayatPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus = 'INITIAL';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(
    String label,
    String? statusValue,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedStatus == statusValue;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
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
    final historyAsync = ref.watch(historyControllerProvider);

    // Set dynamic default status if not initialized
    historyAsync.whenData((list) {
      if (_selectedStatus == 'INITIAL') {
        final hasOngoing = list.any((r) => r.event.status == EventStatus.ongoing);
        _selectedStatus = hasOngoing ? 'ONGOING' : 'PUBLISHED';
      }
    });

    final filteredHistoryAsync = historyAsync.whenData((list) {
      // 1. Sort by closest registered event date
      final sortedList = List<ActivityRecord>.from(list);
      sortedList.sort((a, b) {
        final dateA = a.event.sessions.isEmpty
            ? a.event.createdAt
            : a.event.sessions.map((s) => s.startTime).reduce((x, y) => x.isBefore(y) ? x : y);
        final dateB = b.event.sessions.isEmpty
            ? b.event.createdAt
            : b.event.sessions.map((s) => s.startTime).reduce((x, y) => x.isBefore(y) ? x : y);

        if (_selectedStatus == 'COMPLETED') {
          return dateB.compareTo(dateA); // Descending (newest first)
        }
        return dateA.compareTo(dateB); // Ascending (closest first)
      });

      // 2. Filter by status
      var result = sortedList;
      if (_selectedStatus != 'INITIAL' && _selectedStatus != null) {
        final statusEnum = _selectedStatus == 'ONGOING'
            ? EventStatus.ongoing
            : _selectedStatus == 'PUBLISHED'
            ? EventStatus.published
            : EventStatus.completed;
        result = result.where((r) => r.event.status == statusEnum).toList();
      }

      // 3. Filter by search query
      if (_searchQuery.isNotEmpty) {
        result = result
            .where((r) => r.event.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      return result;
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              KegiatinAppBar(
                height: null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (context.canPop()) ...[
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
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Riwayat Kegiatan',
                      style: textTheme.headlineLarge?.copyWith(color: colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    filteredHistoryAsync.maybeWhen(
                      data: (list) => Text(
                        '${list.length} Kegiatan Tersedia',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      orElse: () => Text(
                        'Memuat riwayat...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Cari Kegiatan...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterChip('Berlangsung', 'ONGOING', colorScheme, textTheme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Akan Datang', 'PUBLISHED', colorScheme, textTheme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Selesai', 'COMPLETED', colorScheme, textTheme),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semua', null, colorScheme, textTheme),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: filteredHistoryAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        'Gagal memuat riwayat: $e',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada riwayat'
                                : 'Pencarian tidak ditemukan',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: list.map((r) => PesertaActivityHistoryCard(record: r)).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
