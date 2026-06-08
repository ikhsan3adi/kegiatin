import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/pages/peserta/peserta_dashboard_page.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/widgets/event_list_card.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';
import '../auth/login_flow_test.dart';

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

    // Stub local storage for logged-in member state
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);

    final memberUser = tUser(displayName: 'Peserta Test');

    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: memberUser)),
    ];
  });

  testWidgets('IT-PST-01: Dashboard menampilkan nama peserta', (tester) async {
    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: any(named: 'status'),
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult([])));

    await tester.pumpApp(const PesertaDashboardPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.text('Peserta Test'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });

  testWidgets('IT-PST-02: Dashboard menampilkan kegiatan terkini (ONGOING + PUBLISHED)', (tester) async {
    final events = [
      tEvent(id: '1', title: 'Ongoing Event', status: EventStatus.ongoing),
      tEvent(id: '2', title: 'Published Event', status: EventStatus.published),
      tEvent(id: '3', title: 'Draft Event', status: EventStatus.draft),
      tEvent(id: '4', title: 'Completed Event', status: EventStatus.completed),
    ];

    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: any(named: 'status'),
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult(events)));

    await tester.pumpApp(const PesertaDashboardPage(), overrides: overrides);
    await tester.pumpAndSettle();

    // Only ongoing and published should be displayed
    expect(find.byType(EventListCard), findsNWidgets(2));
    expect(find.text('Ongoing Event'), findsOneWidget);
    expect(find.text('Published Event'), findsOneWidget);
    expect(find.text('Draft Event'), findsNothing);
    expect(find.text('Completed Event'), findsNothing);
  });

  testWidgets('IT-PST-03: Dashboard — empty state saat tidak ada kegiatan terbaru', (tester) async {
    final events = [
      tEvent(id: '1', title: 'Completed Event', status: EventStatus.completed),
    ];

    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: any(named: 'status'),
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult(events)));

    await tester.pumpApp(const PesertaDashboardPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kegiatan terbaru'), findsOneWidget);
    expect(find.byType(EventListCard), findsNothing);
  });
}
