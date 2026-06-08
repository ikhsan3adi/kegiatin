import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class DeleteNotificationUseCase extends UseCase<void, String> {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.delete(id);
  }
}
