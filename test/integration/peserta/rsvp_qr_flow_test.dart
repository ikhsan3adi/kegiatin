import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/domain/enums/rsvp_status.dart';
import 'package:kegiatin/presentation/pages/peserta/event_detail/peserta_event_detail_page.dart';
import 'package:kegiatin/presentation/pages/peserta/qr_display/qr_display_page.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(EventStatus.draft);
    registerFallbackValue(EventType.single);
  });

  late TestAppMocks mocks;
  late List<Override> overrides;
  final event = tEvent(id: 'event-1', title: 'Kajian Pemuda', status: EventStatus.published);

  setUp(() {
    mocks = TestAppMocks();

    // Stub local storage for logged-in member state
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);

    final memberUser = tMemberUser();

    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: memberUser)),
    ];

    // Default stubs
    when(() => mocks.eventRepository.getEventById('event-1')).thenAnswer((_) async => Right(event));
    when(() => mocks.profileRepository.getHistory()).thenAnswer((_) async => const Right([]));
  });

  testWidgets('IT-RSVP-01: RSVP berhasil → status CONFIRMED', (tester) async {
    // Return no RSVP at first
    when(
      () => mocks.rsvpRepository.getMyRsvps(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult([])));

    // RSVP creation returns success
    when(
      () => mocks.rsvpRepository.createRsvp('event-1'),
    ).thenAnswer((_) async => Right(tRsvp(eventId: 'event-1', status: RsvpStatus.confirmed)));

    await tester.pumpApp(const PesertaEventDetailPage(eventId: 'event-1'), overrides: overrides);
    await tester.pumpAndSettle();

    // Tap Daftar Kegiatan button
    final rsvpButton = find.text('Daftar Kegiatan');
    expect(rsvpButton, findsOneWidget);
    await tester.tap(rsvpButton);
    await tester.pumpAndSettle();

    // Confirm dialog should appear
    expect(find.text('Konfirmasi RSVP'), findsOneWidget);
    final yesButton = find.text('Ya, Daftar');

    // Stub updated getMyRsvps to return the newly created RSVP so UI updates
    when(
      () => mocks.rsvpRepository.getMyRsvps(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          Right(tPaginatedResult([tRsvp(eventId: 'event-1', status: RsvpStatus.confirmed)])),
    );

    await tester.tap(yesButton);
    await tester.pumpAndSettle();

    verify(() => mocks.rsvpRepository.createRsvp('event-1')).called(1);

    // Button should switch to "Lihat QR"
    expect(find.text('Lihat QR'), findsOneWidget);

    // Cleanup snackbar
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('IT-RSVP-02: RSVP gagal — sudah terdaftar', (tester) async {
    when(
      () => mocks.rsvpRepository.getMyRsvps(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult([])));

    // RSVP creation returns error
    when(
      () => mocks.rsvpRepository.createRsvp('event-1'),
    ).thenAnswer((_) async => const Left(ServerFailure('Already registered')));

    await tester.pumpApp(const PesertaEventDetailPage(eventId: 'event-1'), overrides: overrides);
    await tester.pumpAndSettle();

    final rsvpButton = find.text('Daftar Kegiatan');
    await tester.tap(rsvpButton);
    await tester.pumpAndSettle();

    final yesButton = find.text('Ya, Daftar');
    await tester.tap(yesButton);
    await tester.pumpAndSettle();

    expect(find.text('Mengerti'), findsOneWidget);
    expect(find.textContaining('Already registered'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('IT-RSVP-03: QR Display — menampilkan QR code dari RSVP token', (tester) async {
    final rsvp = tRsvp(eventId: 'event-1', qrToken: 'qr-token-123', status: RsvpStatus.confirmed);
    when(
      () => mocks.rsvpRepository.getMyRsvps(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult([rsvp])));

    await tester.pumpApp(const PesertaQrDisplayPage(eventId: 'event-1'), overrides: overrides);
    await tester.pumpAndSettle();

    // Verify QrImageView exists
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
