import 'package:flutter/material.dart';
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

class PesertaRiwayatPage extends ConsumerWidget {
  const PesertaRiwayatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final historyAsync = ref.watch(historyControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            KegiatinAppBar(
              child: Text(
                'Riwayat',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: historyAsync.when(
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
                          'Belum ada riwayat',
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
