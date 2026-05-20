import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/repositories/user_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class SearchUsersUseCase extends UseCase<PaginatedResult<UserSummary>, SearchUsersParams> {
  final UserRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResult<UserSummary>>> call(SearchUsersParams input) =>
      repository.searchUsers(query: input.query, page: input.page, limit: input.limit);
}

class SearchUsersParams {
  final String query;
  final int page;
  final int limit;

  const SearchUsersParams({required this.query, this.page = 1, this.limit = 20});
}
