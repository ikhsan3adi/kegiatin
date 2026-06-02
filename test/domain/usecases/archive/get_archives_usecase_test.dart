import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/archive/get_archives_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockArchiveRepository repository;
  late GetArchivesUseCase useCase;

  setUp(() {
    repository = MockArchiveRepository();
    useCase = GetArchivesUseCase(repository);
  });

  test('returns Right(List<ArchiveItem>) on success', () async {
    final list = [tArchiveItem()];
    when(() => repository.getArchives(any())).thenAnswer((_) async => Right(list));

    const params = GetArchivesParams(sessionId: 'session-1');
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.getArchives('session-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getArchives('session-1'),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    const params = GetArchivesParams(sessionId: 'session-1');
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
