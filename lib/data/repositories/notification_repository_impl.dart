import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/datasources/local/notification_local_datasource.dart';
import 'package:kegiatin/data/models/notification_model.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<NotificationItem>>> getAll() async {
    try {
      final result = await localDataSource.getAllNotifications();
      return Right(result.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> add(NotificationItem item) async {
    try {
      await localDataSource.addNotification(NotificationModel.fromEntity(item));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await localDataSource.markAsRead(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await localDataSource.markAllAsRead();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await localDataSource.deleteNotification(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await localDataSource.getUnreadCount();
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Terjadi kesalahan tak terduga: $e'));
    }
  }
}
