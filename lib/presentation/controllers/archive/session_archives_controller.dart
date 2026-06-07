import 'package:kegiatin/domain/entities/archive_item.dart';
import 'package:kegiatin/domain/usecases/archive/get_archives_usecase.dart';
import 'package:kegiatin/presentation/providers/archive_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_archives_controller.g.dart';

@riverpod
class SessionArchivesController extends _$SessionArchivesController {
  @override
  FutureOr<List<ArchiveItem>> build(String sessionId) async {
    return _fetch(sessionId);
  }

  Future<List<ArchiveItem>> _fetch(String sessionId) async {
    final useCase = ref.read(getArchivesUseCaseProvider);
    final result = await useCase(GetArchivesParams(sessionId: sessionId));
    return result.fold((failure) => throw Exception(failure.message), (data) => data);
  }

  Future<ArchiveItem> downloadArchive(ArchiveItem item) async {
    final useCase = ref.read(downloadArchiveUseCaseProvider);
    final result = await useCase(item);

    return result.fold((failure) => throw Exception(failure.message), (updatedItem) {
      final currentList = state.value;
      if (currentList != null) {
        final newList = currentList.map((a) {
          return a.id == updatedItem.id ? updatedItem : a;
        }).toList();
        state = AsyncData(newList);
      }
      return updatedItem;
    });
  }
}
