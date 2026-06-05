import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/user_summary.dart';
import 'package:kegiatin/domain/usecases/user/search_users_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockUserRepository repository;
  late SearchUsersUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = SearchUsersUseCase(repository);
  });

  test('returns Right(PaginatedResult<UserSummary>) on success', () async {
    final resultData = tPaginatedResult<UserSummary>([tUserSummary()]);
    when(
      () => repository.searchUsers(
        query: any(named: 'query'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right(resultData));

    const params = SearchUsersParams(query: 'test', page: 1, limit: 20);
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.searchUsers(query: 'test', page: 1, limit: 20)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.searchUsers(
        query: any(named: 'query'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Search failed')));

    final result = await useCase(const SearchUsersParams(query: 'test'));

    expect(result.isLeft(), true);
  });
}
