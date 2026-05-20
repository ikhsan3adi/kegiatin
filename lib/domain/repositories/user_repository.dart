import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';

abstract class UserRepository {
  Future<Either<Failure, PaginatedResult<UserSummary>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  });
}
