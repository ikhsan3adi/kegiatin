import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/attendance/record_attendance_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockAttendanceRepository repository;
  late RecordAttendanceUseCase useCase;

  setUp(() {
    repository = MockAttendanceRepository();
    useCase = RecordAttendanceUseCase(repository);
  });

  test('returns Right(Attendance) on success', () async {
    final attendance = tAttendance();
    when(() => repository.scanQr(any(), any())).thenAnswer((_) async => Right(attendance));

    const params = RecordAttendanceParams(qrToken: 'qr-token', sessionId: 'session-1');
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.scanQr('qr-token', 'session-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.scanQr(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Scan failed')));

    const params = RecordAttendanceParams(qrToken: 'invalid', sessionId: 'session-1');
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
