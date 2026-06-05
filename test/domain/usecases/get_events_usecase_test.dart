import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockEventRepository repository;
  late GetEventsUseCase useCase;

  setUp(() {
    repository = MockEventRepository();
    useCase = GetEventsUseCase(repository);
  });

  test('returns Right(PaginatedResult<Event>) on success', () async {
    final resultData = tPaginatedResult<Event>([tEvent()]);
    when(
      () => repository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: any(named: 'status'),
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(resultData));

    const params = GetEventsUseCaseParams(page: 2, limit: 5);
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(
      () => repository.getEvents(
        page: 2,
        limit: 5,
        status: null,
        type: null,
        search: null,
        forceRefresh: false,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: any(named: 'status'),
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase(const GetEventsUseCaseParams());

    expect(result.isLeft(), true);
  });
}
