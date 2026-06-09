import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/controllers/attendance/sync_controller.dart';
import 'package:kegiatin/presentation/controllers/attendance/my_attendance_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/fallback_values.dart';

class FakeMyAttendanceController extends MyAttendanceController {
  @override
  FutureOr<List<Attendance>> build() => [];
}

void main() {
  late MockSyncAttendanceUseCase mockSyncAttendanceUseCase;

  setUpAll(() {
    registerUseCaseFallbackValues();
  });

  setUp(() {
    mockSyncAttendanceUseCase = MockSyncAttendanceUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        syncAttendanceUseCaseProvider.overrideWithValue(mockSyncAttendanceUseCase),
        myAttendanceControllerProvider.overrideWith(() => FakeMyAttendanceController()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SyncController', () {
    test('syncNow sets state to AsyncData(null) on success', () async {
      when(() => mockSyncAttendanceUseCase.call(any())).thenAnswer((_) async => const Right(null));

      final container = createContainer();

      expect(container.read(syncControllerProvider).hasValue, true);

      final controller = container.read(syncControllerProvider.notifier);
      await controller.syncNow();

      expect(container.read(syncControllerProvider).hasValue, true);
      expect(container.read(syncControllerProvider).hasError, false);
      verify(() => mockSyncAttendanceUseCase.call(any())).called(1);
    });

    test('syncNow sets state to AsyncError on failure', () async {
      const failure = ServerFailure('Sync failed');
      when(() => mockSyncAttendanceUseCase.call(any())).thenAnswer((_) async => const Left(failure));

      final container = createContainer();

      final controller = container.read(syncControllerProvider.notifier);
      await controller.syncNow();

      expect(container.read(syncControllerProvider).hasError, true);
      expect(container.read(syncControllerProvider).error, equals(failure));
      verify(() => mockSyncAttendanceUseCase.call(any())).called(1);
    });
  });
}
