import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/history_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/history_remote_datasource.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final HistoryRemoteDataSource historyRemoteDataSource;
  final HistoryLocalDataSource historyLocalDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.historyRemoteDataSource,
    required this.historyLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getProfile() async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, User>> updateProfile({String? displayName, String? photoUrl}) async {
    return const Left(ServerFailure('Belum diimplementasi'));
  }

  @override
  Future<Either<Failure, List<ActivityRecord>>> getHistory({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final cacheKey = 'p${page}_l${limit}_${search ?? ''}';
    if (await networkInfo.isConnected) {
      try {
        final models = await historyRemoteDataSource.getHistory(
          page: page,
          limit: limit,
          search: search,
        );
        await historyLocalDataSource.cacheHistory(cacheKey, models);
        return Right(
          models
              .map(
                (m) => ActivityRecord(
                  event: m.event,
                  attendancePerSession: m.attendancePerSession
                      .map(
                        (a) => SessionAttendance(
                          session: a.session,
                          status: a.status,
                          checkedInAt: a.checkedInAt,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        );
      } on Exception catch (e) {
        final cached = await historyLocalDataSource.getCachedHistory(cacheKey);
        if (cached.isNotEmpty) {
          return Right(
            cached
                .map(
                  (m) => ActivityRecord(
                    event: m.event,
                    attendancePerSession: m.attendancePerSession
                        .map(
                          (a) => SessionAttendance(
                            session: a.session,
                            status: a.status,
                            checkedInAt: a.checkedInAt,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          );
        }
        return Left(ServerFailure(e.toString()));
      }
    }
    final cached = await historyLocalDataSource.getCachedHistory(cacheKey);
    if (cached.isNotEmpty) {
      return Right(
        cached
            .map(
              (m) => ActivityRecord(
                event: m.event,
                attendancePerSession: m.attendancePerSession
                    .map(
                      (a) => SessionAttendance(
                        session: a.session,
                        status: a.status,
                        checkedInAt: a.checkedInAt,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
    }
    return const Left(NetworkFailure());
  }
}
