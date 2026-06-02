import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/usecases/rsvp/invite_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late MockRsvpRepository repository;
  late InviteUserUseCase useCase;

  setUp(() {
    repository = MockRsvpRepository();
    useCase = InviteUserUseCase(repository);
  });

  test('returns Right(Rsvp) on success', () async {
    final rsvp = tRsvp();
    when(() => repository.inviteUser(any(), any())).thenAnswer((_) async => Right(rsvp));

    const params = InviteUserParams(eventId: 'event-1', userId: 'user-2');
    final result = await useCase(params);

    expect(result.isRight(), true);
    verify(() => repository.inviteUser('event-1', 'user-2')).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Left(Failure) on failure', () async {
    when(
      () => repository.inviteUser(any(), any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Invite failed')));

    const params = InviteUserParams(eventId: 'event-1', userId: 'user-2');
    final result = await useCase(params);

    expect(result.isLeft(), true);
  });
}
