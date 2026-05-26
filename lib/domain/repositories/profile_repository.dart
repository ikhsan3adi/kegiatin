import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/activity_record.dart';
import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile(UpdateProfileInput input);
  Future<Either<Failure, List<ActivityRecord>>> getHistory({
    int page = 1,
    int limit = 20,
    String? search,
    bool forceRefresh = false,
  });
}

