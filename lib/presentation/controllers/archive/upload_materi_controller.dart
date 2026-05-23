import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/usecases/archive/upload_materi_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_materi_controller.g.dart';

class UploadMateriArgs {
  final String sessionId;
  final String title;
  final ArchiveType type;
  final String? filePath;
  final String? linkUrl;

  const UploadMateriArgs({
    required this.sessionId,
    required this.title,
    required this.type,
    this.filePath,
    this.linkUrl,
  });
}

@riverpod
class UploadMateriController extends _$UploadMateriController {
  @override
  FutureOr<void> build() {}

  Future<void> upload(UploadMateriArgs args) async {
    state = const AsyncLoading();
    final useCase = ref.read(uploadMateriUseCaseProvider);
    final result = await useCase(
      UploadMateriParams(
        sessionId: args.sessionId,
        title: args.title,
        type: args.type,
        filePath: args.filePath,
        linkUrl: args.linkUrl,
      ),
    );
    state = result.fold(
      (failure) => AsyncError(Exception(failure.message), StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}
