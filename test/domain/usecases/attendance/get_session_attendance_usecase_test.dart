import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/attendance/get_session_attendance_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockAttendanceRepository repository;
  late GetSessionAttendanceUseCase useCase;

  setUp(() {
    repository = MockAttendanceRepository();
    useCase = GetSessionAttendanceUseCase(repository);
  });

  test('returns Right(List<Attendance>) on success', () async {
    final list = [tAttendance()];
    when(() => repository.getAttendanceBySession(any())).thenAnswer((_) async => Right(list));

    final result = await useCase('session-1');

    expect(result.isRight(), true);
    verify(() => repository.getAttendanceBySession('session-1')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.getAttendanceBySession(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Failed')));

    final result = await useCase('session-1');

    expect(result.isLeft(), true);
  });
}
