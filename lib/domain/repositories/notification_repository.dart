import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getAll();
  Future<Either<Failure, void>> add(NotificationItem item);
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, void>> clearAll();
  Future<Either<Failure, int>> getUnreadCount();
}
