import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/rsvp_with_user.dart';
import 'package:kegiatin/domain/usecases/get_event_rsvps_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockRsvpRepository repository;
  late GetEventRsvpsUseCase useCase;

  setUp(() {
    repository = MockRsvpRepository();
    useCase = GetEventRsvpsUseCase(repository);
  });

  test('returns Right(PaginatedResult<RsvpWithUser>) on success', () async {
    final resultData = tPaginatedResult<RsvpWithUser>([tRsvpWithUser()]);
    when(
      () => repository.getEventRsvps(
        any(),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => Right(resultData));

    const params = GetEventRsvpsParams(eventId: 'event-1', search: 'test');
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(
      () => repository.getEventRsvps('event-1', page: 1, limit: 100, search: 'test'),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getEventRsvps(
        any(),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase(const GetEventRsvpsParams(eventId: 'event-1'));

    expect(result.isLeft(), true);
  });
}
