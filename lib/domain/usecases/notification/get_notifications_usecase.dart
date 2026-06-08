import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetNotificationsUseCase extends UseCase<List<NotificationItem>, NoInput> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationItem>>> call(NoInput input) {
    return repository.getAll();
  }
}
