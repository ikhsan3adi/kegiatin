import 'package:kegiatin/data/datasources/remote/event_remote_datasource.dart';
import 'package:kegiatin/data/repositories/event_repository_impl.dart';
import 'package:kegiatin/domain/repositories/event_repository.dart';
import 'package:kegiatin/domain/usecases/cancel_event_usecase.dart';
import 'package:kegiatin/domain/usecases/complete_event_usecase.dart';
import 'package:kegiatin/domain/usecases/create_event_usecase.dart';
import 'package:kegiatin/domain/usecases/get_event_by_id_usecase.dart';
import 'package:kegiatin/domain/usecases/get_events_usecase.dart';
import 'package:kegiatin/domain/usecases/publish_event_usecase.dart';
import 'package:kegiatin/domain/usecases/start_event_usecase.dart';
import 'package:kegiatin/domain/usecases/event/update_event_usecase.dart';
import 'package:kegiatin/presentation/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_providers.g.dart';

/// Event remote DS, repository, and use cases.

@Riverpod(keepAlive: true)
EventRemoteDataSource eventRemoteDataSource(Ref ref) =>
    EventRemoteDataSourceImpl(ref.watch(dioClientProvider).dio);

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) =>
    EventRepositoryImpl(remoteDataSource: ref.watch(eventRemoteDataSourceProvider));

@riverpod
GetEventsUseCase getEventsUseCase(Ref ref) => GetEventsUseCase(ref.watch(eventRepositoryProvider));

@riverpod
GetEventByIdUseCase getEventByIdUseCase(Ref ref) =>
    GetEventByIdUseCase(ref.watch(eventRepositoryProvider));

@riverpod
CreateEventUseCase createEventUseCase(Ref ref) =>
    CreateEventUseCase(ref.watch(eventRepositoryProvider));

@riverpod
PublishEventUseCase publishEventUseCase(Ref ref) =>
    PublishEventUseCase(ref.watch(eventRepositoryProvider));

@riverpod
StartEventUseCase startEventUseCase(Ref ref) =>
    StartEventUseCase(ref.watch(eventRepositoryProvider));

@riverpod
CompleteEventUseCase completeEventUseCase(Ref ref) =>
    CompleteEventUseCase(ref.watch(eventRepositoryProvider));

@riverpod
CancelEventUseCase cancelEventUseCase(Ref ref) =>
    CancelEventUseCase(ref.watch(eventRepositoryProvider));

@riverpod
UpdateEventUseCase updateEventUseCase(Ref ref) =>
    UpdateEventUseCase(ref.watch(eventRepositoryProvider));
