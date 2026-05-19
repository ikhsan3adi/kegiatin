import 'package:hive_ce/hive.dart';
import 'package:kegiatin/data/datasources/local/attendance_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:kegiatin/data/repositories/attendance_repository_impl.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';
import 'package:kegiatin/domain/usecases/attendance/get_session_attendance_usecase.dart';
import 'package:kegiatin/domain/usecases/attendance/record_attendance_usecase.dart';
import 'package:kegiatin/domain/usecases/attendance/sync_attendance_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_providers.g.dart';

@Riverpod(keepAlive: true)
Box<dynamic> attendanceBox(Ref ref) => throw UnimplementedError('Override di ProviderScope');

@Riverpod(keepAlive: true)
AttendanceLocalDataSource attendanceLocalDataSource(Ref ref) =>
    AttendanceLocalDataSourceImpl(attendanceBox: ref.watch(attendanceBoxProvider));

@Riverpod(keepAlive: true)
AttendanceRemoteDataSource attendanceRemoteDataSource(Ref ref) =>
    AttendanceRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(Ref ref) => AttendanceRepositoryImpl(
  remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
  localDataSource: ref.watch(attendanceLocalDataSourceProvider),
  networkInfo: ref.watch(networkInfoProvider),
);

@riverpod
RecordAttendanceUseCase recordAttendanceUseCase(Ref ref) =>
    RecordAttendanceUseCase(ref.watch(attendanceRepositoryProvider));

@riverpod
SyncAttendanceUseCase syncAttendanceUseCase(Ref ref) =>
    SyncAttendanceUseCase(ref.watch(attendanceRepositoryProvider));

@riverpod
GetSessionAttendanceUseCase getSessionAttendanceUseCase(Ref ref) =>
    GetSessionAttendanceUseCase(ref.watch(attendanceRepositoryProvider));
