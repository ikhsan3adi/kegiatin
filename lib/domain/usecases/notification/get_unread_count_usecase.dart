import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/repositories/notification_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetUnreadCountUseCase extends UseCase<int, NoInput> {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoInput input) {
    return repository.getUnreadCount();
  }
}
