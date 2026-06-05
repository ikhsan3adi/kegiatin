import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/session/delete_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';

void main() {
  late MockSessionRepository repository;
  late DeleteSessionUseCase useCase;

  setUp(() {
    repository = MockSessionRepository();
    useCase = DeleteSessionUseCase(repository);
  });

  test('returns Right(void) on success', () async {
    when(() => repository.deleteSession(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase('session-1');

    expect(result, const Right(null));
    verify(() => repository.deleteSession('session-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.deleteSession('session-1'),
    ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

    final result = await useCase('session-1');

    expect(result.isLeft(), true);
  });
}
