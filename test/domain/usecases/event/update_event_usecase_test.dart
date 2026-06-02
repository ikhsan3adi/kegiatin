import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/event/update_event_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fallback_values.dart';
import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockEventRepository repository;
  late UpdateEventUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockEventRepository();
    useCase = UpdateEventUseCase(repository);
  });

  test('returns Right(Event) on success', () async {
    final event = tEvent();
    when(() => repository.updateEvent(any(), any())).thenAnswer((_) async => Right(event));

    final params = UpdateEventUseCaseParams(eventId: 'event-1', input: tUpdateEventInput());
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.updateEvent('event-1', tUpdateEventInput())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.updateEvent(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

    final params = UpdateEventUseCaseParams(eventId: 'event-1', input: tUpdateEventInput());
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
