import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/get_history_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockProfileRepository repository;
  late GetHistoryUseCase useCase;

  setUp(() {
    repository = MockProfileRepository();
    useCase = GetHistoryUseCase(repository);
  });

  test('returns Right(List<ActivityRecord>) on success', () async {
    final records = [tActivityRecord()];
    when(
      () => repository.getHistory(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(records));

    final result = await useCase(const GetHistoryParams());

    expect(result.isRight(), true);
    verify(
      () => repository.getHistory(page: 1, limit: 20, search: null, forceRefresh: false),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getHistory(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase(const GetHistoryParams());

    expect(result.isLeft(), true);
  });
}
