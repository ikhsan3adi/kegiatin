import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/session/add_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fallback_values.dart';
import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockSessionRepository repository;
  late AddSessionUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockSessionRepository();
    useCase = AddSessionUseCase(repository);
  });

  test('returns Right(Session) on success', () async {
    final session = tSession();
    final input = tSessionInput();
    when(() => repository.addSession(any(), any())).thenAnswer((_) async => Right(session));

    final params = AddSessionParams(eventId: 'event-1', input: input);
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.addSession('event-1', input)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    final input = tSessionInput();
    when(
      () => repository.addSession(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));

    final params = AddSessionParams(eventId: 'event-1', input: input);
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
