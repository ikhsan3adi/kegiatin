import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/attendance/sync_attendance_usecase.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';

void main() {
  late MockAttendanceRepository repository;
  late SyncAttendanceUseCase useCase;

  setUp(() {
    repository = MockAttendanceRepository();
    useCase = SyncAttendanceUseCase(repository);
  });

  test('returns Right(void) on success', () async {
    when(() => repository.syncPendingAttendance()).thenAnswer((_) async => const Right(null));

    final result = await useCase(const NoInput());

    expect(result, const Right(null));
    verify(() => repository.syncPendingAttendance()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.syncPendingAttendance(),
    ).thenAnswer((_) async => const Left(ServerFailure('Sync failed')));

    final result = await useCase(const NoInput());

    expect(result.isLeft(), true);
  });
}
