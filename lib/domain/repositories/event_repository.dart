import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/create_event_input.dart';
import 'package:kegiatin/domain/entities/event.dart';
import 'package:kegiatin/domain/entities/paginated_result.dart';
import 'package:kegiatin/domain/entities/update_event_input.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';

abstract class EventRepository {
  Future<Either<Failure, PaginatedResult<Event>>> getEvents({
    int page = 1,
    int limit = 10,
    EventStatus? status,
    EventType? type,
    String? search,
  });

  Future<Either<Failure, Event>> getEventById(String id);
  Future<Either<Failure, Event>> createEvent(CreateEventInput input);
  Future<Either<Failure, Event>> updateEvent(String id, UpdateEventInput input);
  Future<Either<Failure, void>> deleteEvent(String id);
  Future<Either<Failure, Event>> publishEvent(String id);
  Future<Either<Failure, Event>> cancelEvent(String id);
}
