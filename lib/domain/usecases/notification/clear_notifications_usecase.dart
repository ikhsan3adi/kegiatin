import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class ClearNotificationsUseCase extends UseCase<void, NoInput> {
  final NotificationRepository repository;

  ClearNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoInput input) {
    return repository.clearAll();
  }
}
