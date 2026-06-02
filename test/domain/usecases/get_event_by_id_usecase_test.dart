import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/get_event_by_id_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockEventRepository repository;
  late GetEventByIdUseCase useCase;

  setUp(() {
    repository = MockEventRepository();
    useCase = GetEventByIdUseCase(repository);
  });

  test('returns Right(Event) for valid ID', () async {
    final event = tEvent();
    when(() => repository.getEventById(any())).thenAnswer((_) async => Right(event));

    final result = await useCase('event-1');

    expect(result.isRight(), true);
    verify(() => repository.getEventById('event-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) for invalid ID', () async {
    when(
      () => repository.getEventById(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Not found')));

    final result = await useCase('invalid-id');

    expect(result.isLeft(), true);
  });
}
