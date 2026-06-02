import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class UpdateProfileUseCase extends UseCase<User, UpdateProfileInput> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileInput input) => repository.updateProfile(input);
}
