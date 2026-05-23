import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/attendance_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/rsvp_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:kegiatin/data/models/attendance_model.dart';
import 'package:kegiatin/data/models/sync_result_model.dart';
import 'package:kegiatin/domain/entities/attendance.dart';
import 'package:kegiatin/domain/enums/attendance_status.dart';
import 'package:kegiatin/domain/enums/sync_status.dart';
import 'package:kegiatin/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final RsvpLocalDataSource rsvpLocalDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.rsvpLocalDataSource,
  });

  @override
  Future<Either<Failure, Attendance>> scanQr(String qrToken, String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.scanQr(qrToken: qrToken, sessionId: sessionId);
        await localDataSource.saveRecord(result);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      }
    }
    try {
      if (await localDataSource.isDuplicateByQrToken(qrToken, sessionId)) {
        return const Left(CacheFailure('Presensi dengan QR ini sudah tercatat sebelumnya.'));
      }

      final rsvp = await rsvpLocalDataSource.getRsvpByQrToken(qrToken);
      if (rsvp == null) {
        return const Left(CacheFailure('Tiket QR tidak terdaftar untuk kegiatan ini.'));
      }

      final record = AttendanceModel(
        id: const Uuid().v4(),
        userId: rsvp.userId,
        sessionId: sessionId,
        rsvpId: rsvp.id,
        status: AttendanceStatus.present,
        syncStatus: SyncStatus.pending,
        qrToken: qrToken,
        checkedInAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await localDataSource.saveRecord(record);
      return Right(record.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingAttendance() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final pending = await localDataSource.getPendingRecords();
      if (pending.isEmpty) return const Right(null);

      for (final r in pending) {
        await localDataSource.updateSyncStatus(r.id, SyncStatus.syncing);
      }

      final syncRecords = pending
          .map(
            (r) => SyncAttendanceRecord(
              localId: r.id,
              qrToken: r.qrToken ?? '',
              sessionId: r.sessionId,
              checkedInAt: r.checkedInAt,
            ),
          )
          .toList();

      final result = await remoteDataSource.syncBatch(syncRecords);

      for (final item in result.results) {
        final newStatus = switch (item.status) {
          'SYNCED' => SyncStatus.synced,
          'CONFLICT' => SyncStatus.synced,
          _ => SyncStatus.conflict,
        };
        await localDataSource.updateSyncStatus(item.localId, newStatus);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attendance>>> getAttendanceBySession(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSessionAttendance(sessionId);
        return Right(result.data.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, statusCode: e.statusCode));
      }
    }
    try {
      final cached = await localDataSource.getRecordsBySession(sessionId);
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
