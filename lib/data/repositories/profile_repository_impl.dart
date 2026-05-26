import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/network/network_info.dart';
import 'package:kegiatin/data/datasources/local/auth_local_datasource.dart';
import 'package:kegiatin/data/datasources/local/history_local_datasource.dart';
import 'package:kegiatin/data/datasources/remote/history_remote_datasource.dart';
import 'package:kegiatin/data/datasources/remote/profile_remote_datasource.dart';
import 'package:kegiatin/data/models/activity_record_model.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;
  final HistoryRemoteDataSource historyRemoteDataSource;
  final HistoryLocalDataSource historyLocalDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.profileRemoteDataSource,
    required this.historyRemoteDataSource,
    required this.historyLocalDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getProfile() async {
    if (!await networkInfo.isConnected) {
      final cached = await authLocalDataSource.getCachedUser();
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure());
    }
    try {
      final user = await profileRemoteDataSource.getProfile();
      await authLocalDataSource.saveUser(user);
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileInput input) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await profileRemoteDataSource.updateProfile(input);
      // Sinkronkan cached user agar UI dan sesi offline konsisten.
      await authLocalDataSource.saveUser(user);
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityRecord>>> getHistory({
    int page = 1,
    int limit = 20,
    String? search,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'p${page}_l${limit}_${search ?? ''}';
    if (await networkInfo.isConnected) {
      if (forceRefresh) {
        try {
          final models = await historyRemoteDataSource.getHistory(
            page: page,
            limit: limit,
            search: search,
          );
          await historyLocalDataSource.cacheHistory(cacheKey, models);
          return Right(_mapModelsToRecords(models));
        } on Exception catch (e) {
          return Left(ServerFailure(e.toString()));
        }
      }
      try {
        final models = await historyRemoteDataSource.getHistory(
          page: page,
          limit: limit,
          search: search,
        );
        await historyLocalDataSource.cacheHistory(cacheKey, models);
        return Right(_mapModelsToRecords(models));
      } on Exception catch (e) {
        final cached = await historyLocalDataSource.getCachedHistory(cacheKey);
        if (cached.isNotEmpty) {
          return Right(_mapModelsToRecords(cached));
        }
        return Left(ServerFailure(e.toString()));
      }
    }
    final cached = await historyLocalDataSource.getCachedHistory(cacheKey);
    if (cached.isNotEmpty) {
      return Right(_mapModelsToRecords(cached));
    }
    return const Left(NetworkFailure());
  }

  List<ActivityRecord> _mapModelsToRecords(List<ActivityRecordModel> models) {
    return models
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
        .toList();
  }
}
