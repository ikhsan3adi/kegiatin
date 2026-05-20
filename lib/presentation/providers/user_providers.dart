import 'package:kegiatin/data/datasources/remote/user_remote_datasource.dart';
import 'package:kegiatin/data/repositories/user_repository_impl.dart';
import 'package:kegiatin/domain/repositories/user_repository.dart';
import 'package:kegiatin/domain/usecases/user/search_users_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_providers.g.dart';

@Riverpod(keepAlive: true)
UserRemoteDataSource userRemoteDataSource(Ref ref) =>
    UserRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) =>
    UserRepositoryImpl(remoteDataSource: ref.watch(userRemoteDataSourceProvider));

@riverpod
SearchUsersUseCase searchUsersUseCase(Ref ref) =>
    SearchUsersUseCase(ref.watch(userRepositoryProvider));
