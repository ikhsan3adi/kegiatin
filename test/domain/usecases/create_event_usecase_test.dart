import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/create_event_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockEventRepository repository;
  late CreateEventUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockEventRepository();
    useCase = CreateEventUseCase(repository);
  });

  test('returns Right(Event) on success', () async {
    final event = tEvent();
    when(() => repository.createEvent(any())).thenAnswer((_) async => Right(event));

    final result = await useCase(tCreateEventInput());

    expect(result.isRight(), true);
    verify(() => repository.createEvent(any())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.createEvent(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Create failed')));

    final result = await useCase(tCreateEventInput());

    expect(result.isLeft(), true);
  });
}
