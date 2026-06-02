import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/domain/entities/processed_image.dart';
import 'package:kegiatin/domain/repositories/pcd_repository.dart';
import 'package:kegiatin/domain/usecases/pcd/scan_document_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fallback_values.dart';
import '../../../helpers/mock_definitions.dart';

void main() {
  late MockPcdRepository repository;
  late ScanDocumentUseCase useCase;

  setUpAll(registerUseCaseFallbackValues);

  setUp(() {
    repository = MockPcdRepository();
    useCase = ScanDocumentUseCase(repository);
  });

  test('returns Right(ProcessedImage) on success', () async {
    when(
      () => repository.captureDocument(),
    ).thenAnswer((_) async => [CaptureResult(imageBytes: Uint8List(0))]);
    when(
      () => repository.enhanceAndSave(
        imageBytes: any(named: 'imageBytes'),
        mode: any(named: 'mode'),
        isDocumentScan: any(named: 'isDocumentScan'),
      ),
    ).thenAnswer(
      (_) async => const Right(
        ProcessedImage(
          filePath: '/tmp/scan.jpg',
          enhancementMode: 'auto',
          fileSize: 100,
          isDocumentScan: true,
        ),
      ),
    );

    final result = await useCase(EnhancementMode.auto);

    expect(result.isRight(), true);
  });

  test('returns Left(CacheFailure) when capture returns null', () async {
    when(() => repository.captureDocument()).thenAnswer((_) async => null);

    final result = await useCase(EnhancementMode.auto);

    expect(result.isLeft(), true);
    result.fold((failure) => expect(failure, isA<CacheFailure>()), (_) => fail('Expected failure'));
  });

  test('returns Left(CacheFailure) when capture returns empty', () async {
    when(() => repository.captureDocument()).thenAnswer((_) async => []);

    final result = await useCase(EnhancementMode.auto);

    expect(result.isLeft(), true);
  });

  test('returns Left(Failure) when enhance fails', () async {
    when(
      () => repository.captureDocument(),
    ).thenAnswer((_) async => [CaptureResult(imageBytes: Uint8List(0))]);
    when(
      () => repository.enhanceAndSave(
        imageBytes: any(named: 'imageBytes'),
        mode: any(named: 'mode'),
        isDocumentScan: any(named: 'isDocumentScan'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure('Enhance error')));

    final result = await useCase(EnhancementMode.auto);

    expect(result.isLeft(), true);
  });
}
