import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/session/update_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockSessionRepository repository;
  late UpdateSessionUseCase useCase;

  setUp(() {
    repository = MockSessionRepository();
    useCase = UpdateSessionUseCase(repository);
  });

  test('returns Right(Session) on success', () async {
    final session = tSession();
    when(
      () => repository.updateSession(
        any(),
        title: any(named: 'title'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        location: any(named: 'location'),
        capacity: any(named: 'capacity'),
      ),
    ).thenAnswer((_) async => Right(session));

    const params = UpdateSessionParams(id: 'session-1', title: 'Updated');
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.updateSession('session-1', title: 'Updated')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.updateSession(
        any(),
        title: any(named: 'title'),
        startTime: any(named: 'startTime'),
        endTime: any(named: 'endTime'),
        location: any(named: 'location'),
        capacity: any(named: 'capacity'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

    const params = UpdateSessionParams(id: 'session-1');
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
