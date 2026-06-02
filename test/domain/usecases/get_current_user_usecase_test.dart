import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/domain/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockAuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository);
  });

  test('returns Right(User) on success', () async {
    final user = tUser();
    when(() => repository.getCurrentUser()).thenAnswer((_) async => Right(user));

    final result = await useCase(const NoInput());

    expect(result.isRight(), true);
    verify(() => repository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) when fails', () async {
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => const Left(ServerFailure('Not found')));

    final result = await useCase(const NoInput());

    expect(result.isLeft(), true);
  });
}
