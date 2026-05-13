import 'package:kegiatin/data/datasources/remote/rsvp_remote_datasource.dart';
import 'package:kegiatin/data/repositories/rsvp_repository_impl.dart';
import 'package:kegiatin/domain/repositories/rsvp_repository.dart';
import 'package:kegiatin/domain/usecases/create_rsvp_usecase.dart';
import 'package:kegiatin/domain/usecases/get_my_rsvps_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rsvp_providers.g.dart';

/// RSVP remote datasource, repository, dan use cases.

@Riverpod(keepAlive: true)
RsvpRemoteDataSource rsvpRemoteDataSource(Ref ref) =>
    RsvpRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
RsvpRepository rsvpRepository(Ref ref) =>
    RsvpRepositoryImpl(remoteDataSource: ref.watch(rsvpRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
CreateRsvpUseCase createRsvpUseCase(Ref ref) =>
    CreateRsvpUseCase(ref.watch(rsvpRepositoryProvider));

@Riverpod(keepAlive: true)
GetMyRsvpsUseCase getMyRsvpsUseCase(Ref ref) =>
    GetMyRsvpsUseCase(ref.watch(rsvpRepositoryProvider));
