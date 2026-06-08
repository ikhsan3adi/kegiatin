import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/notification_item.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class AddNotificationUseCase extends UseCase<void, NotificationItem> {
  final NotificationRepository repository;

  AddNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NotificationItem input) {
    return repository.add(input);
  }
}
