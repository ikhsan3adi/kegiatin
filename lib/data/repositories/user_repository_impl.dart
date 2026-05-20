import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/datasources/remote/user_remote_datasource.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResult<UserSummary>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchUsers(query: query, page: page, limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
