import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/publish_event_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockEventRepository repository;
  late PublishEventUseCase useCase;

  setUp(() {
    repository = MockEventRepository();
    useCase = PublishEventUseCase(repository);
  });

  test('returns Right(Event) on success', () async {
    final event = tEvent();
    when(() => repository.publishEvent(any())).thenAnswer((_) async => Right(event));

    final result = await useCase('event-1');

    expect(result.isRight(), true);
    verify(() => repository.publishEvent('event-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.publishEvent(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Publish failed')));

    final result = await useCase('event-1');

    expect(result.isLeft(), true);
  });
}
