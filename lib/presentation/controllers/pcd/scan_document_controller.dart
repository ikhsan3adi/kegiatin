import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan_document_controller.g.dart';

@riverpod
class ScanDocumentController extends _$ScanDocumentController {
  @override
  AsyncValue<ProcessedImage?> build() => const AsyncData(null);

  Future<String?> scan(EnhancementMode mode) async {
    state = const AsyncLoading();
    final result = await ref.read(scanDocumentUseCaseProvider).call(mode);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (processedImage) {
        state = AsyncData(processedImage);
        return null;
      },
    );
  }

  void reset() => state = const AsyncData(null);
}
