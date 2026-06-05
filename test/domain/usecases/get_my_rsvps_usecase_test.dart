import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/rsvp.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/domain/usecases/get_my_rsvps_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockRsvpRepository repository;
  late GetMyRsvpsUseCase useCase;

  setUp(() {
    repository = MockRsvpRepository();
    useCase = GetMyRsvpsUseCase(repository);
  });

  test('returns Right(PaginatedResult<Rsvp>) on success', () async {
    final resultData = tPaginatedResult<Rsvp>([tRsvp()]);
    when(() => repository.getMyRsvps()).thenAnswer((_) async => Right(resultData));

    final result = await useCase(const NoInput());

    expect(result.isRight(), true);
    verify(() => repository.getMyRsvps()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getMyRsvps(),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase(const NoInput());

    expect(result.isLeft(), true);
  });
}
