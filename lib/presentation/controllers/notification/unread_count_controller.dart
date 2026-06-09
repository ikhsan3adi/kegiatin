import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/controllers/notification/notification_controller.dart';
import 'package:kegiatin/presentation/providers/notification_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unread_count_controller.g.dart';

@riverpod
class UnreadCountController extends _$UnreadCountController {
  @override
  FutureOr<int> build() async {
    // Watch notification list to re-fetch count when it changes
    ref.watch(notificationControllerProvider);
    
    final useCase = ref.read(getUnreadCountUseCaseProvider);
    final result = await useCase(const NoInput());
    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  }
}
