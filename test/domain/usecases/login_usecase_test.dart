import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('returns Right(AuthResponse) on success', () async {
    final response = tAuthResponse();
    when(() => repository.login(any(), any())).thenAnswer((_) async => Right(response));

    final result = await useCase(tLoginInput());

    expect(result.isRight(), true);
    result.fold((_) {}, (r) => expect(r, response));
    verify(() => repository.login('test@example.com', 'password123')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(AuthFailure) on failure', () async {
    when(
      () => repository.login(any(), any()),
    ).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

    final result = await useCase(tLoginInput());

    expect(result.isLeft(), true);
  });
}
