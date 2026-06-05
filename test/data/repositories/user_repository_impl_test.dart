import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/data/repositories/user_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockUserRemoteDataSource remoteDataSource;
  late UserRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockUserRemoteDataSource();
    repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('searchUsers', () {
    test('returns Right(PaginatedResult<UserSummary>) on success', () async {
      final resultData = tPaginatedResult([tUserSummary()]);
      when(
        () => remoteDataSource.searchUsers(
          query: any(named: 'query'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => resultData);

      final result = await repository.searchUsers(query: 'test', page: 1, limit: 20);

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => remoteDataSource.searchUsers(
          query: any(named: 'query'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const ServerException('Error', statusCode: 500));

      final result = await repository.searchUsers(query: 'test');

      expect(result.isLeft(), true);
    });
  });
}
