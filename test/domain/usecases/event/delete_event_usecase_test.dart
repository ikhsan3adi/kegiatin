import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/event/delete_event_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';

void main() {
  late MockEventRepository repository;
  late DeleteEventUseCase useCase;

  setUp(() {
    repository = MockEventRepository();
    useCase = DeleteEventUseCase(repository);
  });

  test('returns Right(void) on success', () async {
    when(() => repository.deleteEvent(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase('event-1');

    expect(result, const Right(null));
    verify(() => repository.deleteEvent('event-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.deleteEvent('event-1'),
    ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

    final result = await useCase('event-1');

    expect(result.isLeft(), true);
  });
}
