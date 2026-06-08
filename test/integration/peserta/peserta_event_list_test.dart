import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_event_page.dart';
import 'package:kegiatin/presentation/widgets/event_list_card.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
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

  setUp(() {
    mocks = TestAppMocks();
    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: tMemberUser())),
    ];

    // Mock basic Hive and SharedPreferences responses
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);
  });

  testWidgets('IT-PST-04: Event list menampilkan daftar kegiatan', (tester) async {
    final events = [
      tEvent(id: '1', title: 'Kegiatan A', status: EventStatus.ongoing),
      tEvent(id: '2', title: 'Kegiatan B', status: EventStatus.ongoing),
    ];

    when(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: EventStatus.ongoing,
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult(events)));

    await tester.pumpApp(const PesertaEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.byType(EventListCard), findsNWidgets(2));
    expect(find.text('Kegiatan A'), findsOneWidget);
    expect(find.text('Kegiatan B'), findsOneWidget);
  });

  testWidgets('IT-PST-05: Event list — filter chip berfungsi', (tester) async {
    // ONGOING stub
    when(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: EventStatus.ongoing,
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult([])));

    // COMPLETED stub
    when(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: EventStatus.completed,
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult([])));

    await tester.pumpApp(const PesertaEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    // Tap 'Selesai' chip
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    verify(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: EventStatus.completed,
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).called(greaterThanOrEqualTo(1));
  });
}
