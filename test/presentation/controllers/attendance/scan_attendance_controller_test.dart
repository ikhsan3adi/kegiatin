import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/usecases/attendance/record_attendance_usecase.dart';
import 'package:kegiatin/presentation/controllers/attendance/scan_attendance_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/my_attendance_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';
import '../../../helpers/fallback_values.dart';

class FakeMyAttendanceController extends MyAttendanceController {
  @override
  FutureOr<List<Attendance>> build() => [];
}

void main() {
  late MockRecordAttendanceUseCase mockRecordAttendanceUseCase;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    mockRecordAttendanceUseCase = MockRecordAttendanceUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        recordAttendanceUseCaseProvider.overrideWithValue(mockRecordAttendanceUseCase),
        myAttendanceControllerProvider.overrideWith(() => FakeMyAttendanceController()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ScanAttendanceController', () {
    test('scan sets state to AsyncData(attendance) on success', () async {
      final attendance = tAttendance();
      when(() => mockRecordAttendanceUseCase.call(any())).thenAnswer((_) async => Right(attendance));

      final container = createContainer();

      expect(container.read(scanAttendanceControllerProvider).value, isNull);

      final controller = container.read(scanAttendanceControllerProvider.notifier);
      await controller.scan('qr-token', 'session-1');

      expect(container.read(scanAttendanceControllerProvider).value, equals(attendance));
      expect(container.read(scanAttendanceControllerProvider).hasError, false);
      verify(() => mockRecordAttendanceUseCase.call(any())).called(1);
    });

    test('scan sets state to AsyncError on failure', () async {
      const failure = ServerFailure('Record failed');
      when(() => mockRecordAttendanceUseCase.call(any())).thenAnswer((_) async => const Left(failure));

      final container = createContainer();

      final controller = container.read(scanAttendanceControllerProvider.notifier);
      await controller.scan('qr-token', 'session-1');

      expect(container.read(scanAttendanceControllerProvider).hasError, true);
      expect(container.read(scanAttendanceControllerProvider).error, equals(failure));
      verify(() => mockRecordAttendanceUseCase.call(any())).called(1);
    });
  });
}
