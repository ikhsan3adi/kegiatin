import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/archive_model.dart';
import 'package:kegiatin/data/repositories/archive_repository_impl.dart';
import 'package:kegiatin/domain/enums/archive_type.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockArchiveRemoteDataSource archiveRemoteDataSource;
  late MockUploadsRemoteDataSource uploadsRemoteDataSource;
  late MockArchiveLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late MockDio mockDio;
  late ArchiveRepositoryImpl repository;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    archiveRemoteDataSource = MockArchiveRemoteDataSource();
    uploadsRemoteDataSource = MockUploadsRemoteDataSource();
    localDataSource = MockArchiveLocalDataSource();
    networkInfo = MockNetworkInfo();
    mockDio = MockDio();
    repository = ArchiveRepositoryImpl(
      archiveRemoteDataSource: archiveRemoteDataSource,
      uploadsRemoteDataSource: uploadsRemoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
      dio: mockDio,
    );
  });

  group('createArchive', () {
    test('returns Right(ArchiveItem) on success', () async {
      final entity = tArchiveItem();
      final model = ArchiveModel(
        id: entity.id,
        sessionId: entity.sessionId,
        title: entity.title,
        type: entity.type,
        fileUrl: entity.fileUrl,
        createdAt: entity.createdAt,
      );
      when(
        () => archiveRemoteDataSource.createArchive(
          sessionId: any(named: 'sessionId'),
          title: any(named: 'title'),
          type: any(named: 'type'),
          fileUrl: any(named: 'fileUrl'),
        ),
      ).thenAnswer((_) async => model);

      final result = await repository.createArchive(
        sessionId: 'session-1',
        title: 'Arsip',
        type: ArchiveType.material,
        fileUrl: 'url',
      );

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(
        () => archiveRemoteDataSource.createArchive(
          sessionId: any(named: 'sessionId'),
          title: any(named: 'title'),
          type: any(named: 'type'),
          fileUrl: any(named: 'fileUrl'),
        ),
      ).thenThrow(Exception('Error'));

      final result = await repository.createArchive(
        sessionId: 'session-1',
        title: 'Arsip',
        type: ArchiveType.material,
        fileUrl: 'url',
      );

      expect(result.isLeft(), true);
    });
  });

  group('getArchives', () {
    test('returns remote + cache when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final entity = tArchiveItem();
      final model = ArchiveModel(
        id: entity.id,
        sessionId: entity.sessionId,
        title: entity.title,
        type: entity.type,
        fileUrl: entity.fileUrl,
        createdAt: entity.createdAt,
      );
      when(() => archiveRemoteDataSource.getArchives(any())).thenAnswer((_) async => [model]);
      when(() => localDataSource.getCachedArchives(any())).thenAnswer((_) async => []);
      when(() => localDataSource.cacheArchives(any(), any())).thenAnswer((_) async {});

      final result = await repository.getArchives('session-1');

      expect(result.isRight(), true);
      result.fold((_) {}, (list) => expect(list.length, 1));
    });

    test('falls back to cache on exception', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => archiveRemoteDataSource.getArchives(any())).thenThrow(Exception('Error'));
      final entity = tArchiveItem();
      final model = ArchiveModel(
        id: entity.id,
        sessionId: entity.sessionId,
        title: entity.title,
        type: entity.type,
        fileUrl: entity.fileUrl,
        createdAt: entity.createdAt,
      );
      when(() => localDataSource.getCachedArchives(any())).thenAnswer((_) async => [model]);

      final result = await repository.getArchives('session-1');

      expect(result.isRight(), true);
    });

    test('returns cached data when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final entity = tArchiveItem();
      final model = ArchiveModel(
        id: entity.id,
        sessionId: entity.sessionId,
        title: entity.title,
        type: entity.type,
        fileUrl: entity.fileUrl,
        createdAt: entity.createdAt,
      );
      when(() => localDataSource.getCachedArchives(any())).thenAnswer((_) async => [model]);

      final result = await repository.getArchives('session-1');

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getCachedArchives(any())).thenAnswer((_) async => []);

      final result = await repository.getArchives('session-1');

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('uploadImage', () {
    test('returns Right(url) on success', () async {
      when(
        () => uploadsRemoteDataSource.uploadImage(any()),
      ).thenAnswer((_) async => 'https://cdn.example.com/img.jpg');

      final result = await repository.uploadImage('/tmp/file.jpg');

      expect(result, const Right('https://cdn.example.com/img.jpg'));
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => uploadsRemoteDataSource.uploadImage(any())).thenThrow(Exception('Upload failed'));

      final result = await repository.uploadImage('/tmp/file.jpg');

      expect(result.isLeft(), true);
    });
  });

  group('deleteArchive', () {
    test('returns Right(void) on success', () async {
      when(() => archiveRemoteDataSource.deleteArchive(any())).thenAnswer((_) async {});

      final result = await repository.deleteArchive('archive-1');

      expect(result, const Right(null));
    });

    test('returns Left(ServerFailure) on exception', () async {
      when(() => archiveRemoteDataSource.deleteArchive(any())).thenThrow(Exception('Error'));

      final result = await repository.deleteArchive('archive-1');

      expect(result.isLeft(), true);
    });
  });
}
