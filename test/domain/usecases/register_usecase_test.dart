import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository);
  });

  test('returns Right(User) on success', () async {
    final user = tUser();
    when(() => repository.register(any())).thenAnswer((_) async => Right(user));

    final result = await useCase(tRegisterInput());

    expect(result.isRight(), true);
    verify(() => repository.register(any())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(ServerFailure) on failure', () async {
    when(
      () => repository.register(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Registration failed')));

    final result = await useCase(tRegisterInput());

    expect(result.isLeft(), true);
  });
}
