import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';

abstract class UseCase<Output, Input> {
  Future<Either<Failure, Output>> call(Input input);
}

/// Dipakai sebagai Input untuk use case yang tidak membutuhkan parameter.
class NoInput {
  const NoInput();
  static const instance = NoInput();
}
