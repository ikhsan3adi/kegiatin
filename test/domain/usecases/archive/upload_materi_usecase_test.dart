import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:kegiatin/domain/usecases/archive/upload_materi_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fallback_values.dart';
import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockArchiveRepository repository;
  late UploadMateriUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockArchiveRepository();
    useCase = UploadMateriUseCase(repository);
  });

  test('returns Right(ArchiveItem) with linkUrl for material type', () async {
    final archive = tArchiveItem();
    when(
      () => repository.createArchive(
        sessionId: any(named: 'sessionId'),
        title: any(named: 'title'),
        type: any(named: 'type'),
        fileUrl: any(named: 'fileUrl'),
      ),
    ).thenAnswer((_) async => Right(archive));

    const params = UploadMateriParams(
      sessionId: 'session-1',
      title: 'Materi',
      type: ArchiveType.material,
      linkUrl: 'https://example.com',
    );
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(
      () => repository.createArchive(
        sessionId: 'session-1',
        title: 'Materi',
        type: ArchiveType.material,
        fileUrl: 'https://example.com',
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(CacheFailure) when no file or link provided', () async {
    const params = UploadMateriParams(
      sessionId: 'session-1',
      title: 'Materi',
      type: ArchiveType.photo,
    );
    final result = await useCase(params);

    expect(result.isLeft(), true);
    result.fold((failure) => expect(failure, isA<CacheFailure>()), (_) => fail('Expected failure'));
  });

  test('uploads file and creates archive for photo type', () async {
    when(
      () => repository.uploadImage(any()),
    ).thenAnswer((_) async => const Right('https://cdn.example.com/img.jpg'));
    when(
      () => repository.createArchive(
        sessionId: any(named: 'sessionId'),
        title: any(named: 'title'),
        type: any(named: 'type'),
        fileUrl: any(named: 'fileUrl'),
      ),
    ).thenAnswer((_) async => Right(tArchiveItem()));

    const params = UploadMateriParams(
      sessionId: 'session-1',
      title: 'Photo',
      type: ArchiveType.photo,
      filePath: '/tmp/photo.jpg',
    );
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.uploadImage('/tmp/photo.jpg')).called(1);
    verify(
      () => repository.createArchive(
        sessionId: 'session-1',
        title: 'Photo',
        type: ArchiveType.photo,
        fileUrl: 'https://cdn.example.com/img.jpg',
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) when upload fails', () async {
    when(
      () => repository.uploadImage('/tmp/photo.jpg'),
    ).thenAnswer((_) async => const Left(ServerFailure('Upload failed')));

    const params = UploadMateriParams(
      sessionId: 'session-1',
      title: 'Photo',
      type: ArchiveType.photo,
      filePath: '/tmp/photo.jpg',
    );
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
