import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/repositories/profile_repository.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';

class GetHistoryParams {
  final int page;
  final int limit;
  final String? search;

  const GetHistoryParams({this.page = 1, this.limit = 20, this.search});
}

class GetHistoryUseCase extends UseCase<List<ActivityRecord>, GetHistoryParams> {
  final ProfileRepository repository;

  GetHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ActivityRecord>>> call(GetHistoryParams params) async {
    return repository.getHistory(page: params.page, limit: params.limit, search: params.search);
  }
}
