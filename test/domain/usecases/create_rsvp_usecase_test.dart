import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/create_rsvp_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockRsvpRepository repository;
  late CreateRsvpUseCase useCase;

  setUp(() {
    repository = MockRsvpRepository();
    useCase = CreateRsvpUseCase(repository);
  });

  test('returns Right(Rsvp) on success', () async {
    final rsvp = tRsvp();
    when(() => repository.createRsvp(any())).thenAnswer((_) async => Right(rsvp));

    final result = await useCase('event-1');

    expect(result.isRight(), true);
    verify(() => repository.createRsvp('event-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.createRsvp(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('RSVP failed')));

    final result = await useCase('event-1');

    expect(result.isLeft(), true);
  });
}
