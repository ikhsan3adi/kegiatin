import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/profile/update_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fallback_values.dart';
import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockProfileRepository repository;
  late UpdateProfileUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockProfileRepository();
    useCase = UpdateProfileUseCase(repository);
  });

  test('returns Right(User) on success', () async {
    final user = tUser();
    when(() => repository.updateProfile(any())).thenAnswer((_) async => Right(user));

    final result = await useCase(tUpdateProfileInput());

    expect(result.isRight(), true);
    verify(() => repository.updateProfile(tUpdateProfileInput())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.updateProfile(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

    final result = await useCase(tUpdateProfileInput());

    expect(result.isLeft(), true);
  });
}
