import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/archive/delete_archive_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';

void main() {
  late MockArchiveRepository repository;
  late DeleteArchiveUseCase useCase;

  setUp(() {
    repository = MockArchiveRepository();
    useCase = DeleteArchiveUseCase(repository);
  });

  test('returns Right(void) on success', () async {
    when(() => repository.deleteArchive(any())).thenAnswer((_) async => const Right(null));

    final result = await useCase('archive-1');

    expect(result, const Right(null));
    verify(() => repository.deleteArchive('archive-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.deleteArchive('archive-1'),
    ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

    final result = await useCase('archive-1');

    expect(result.isLeft(), true);
  });
}
