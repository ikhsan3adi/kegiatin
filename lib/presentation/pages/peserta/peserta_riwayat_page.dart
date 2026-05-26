import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/usecases/get_history_usecase.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/peserta_activity_history_card.dart';
import 'package:kegiatin/presentation/providers/history_providers.dart';
import 'package:kegiatin/presentation/widgets/kegiatin_app_bar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'peserta_riwayat_page.g.dart';

@riverpod
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(historyControllerProvider);

    final filteredHistoryAsync = historyAsync.whenData((list) {
      if (_searchQuery.isEmpty) return list;
      return list
          .where((r) => r.event.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });

    return RefreshIndicator(
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
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  filteredHistoryAsync.maybeWhen(
                    data: (list) => Text(
                      '${list.length} Kegiatan Tersedia',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    orElse: () => Text(
                      'Memuat riwayat...',
                      style: textTheme.bodySmall?.copyWith(
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
            Padding(
              padding: const EdgeInsets.all(20),
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
                          _searchQuery.isEmpty ? 'Belum ada riwayat' : 'Pencarian tidak ditemukan',
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
    );
  }
}
