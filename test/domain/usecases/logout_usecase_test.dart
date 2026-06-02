import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_definitions.dart';

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('calls repository.logout() and returns Right(null)', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    final result = await useCase(const NoInput());

    expect(result, const Right(null));
    verify(() => repository.logout()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
