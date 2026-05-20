import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/usecases/user/search_users_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_user_controller.g.dart';

@riverpod
class SearchUserController extends _$SearchUserController {
  @override
  FutureOr<PaginatedResult<UserSummary>?> build() => null;

  Future<void> search(String query, {int page = 1}) async {
    if (query.length < 2) return;
    state = const AsyncLoading();
    final useCase = ref.read(searchUsersUseCaseProvider);
    final result = await useCase(SearchUsersParams(query: query, page: page));
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (data) => AsyncData(data),
    );
  }
}
