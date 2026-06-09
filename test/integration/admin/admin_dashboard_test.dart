import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/pages/admin/admin_dashboard_page.dart';
import 'package:kegiatin/presentation/pages/admin/widget/dashboard_card.dart';
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

    // Stub local storage for logged-in admin state
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);

    final adminUser = tAdminUser();

    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: adminUser)),
    ];
  });

  testWidgets('IT-ADMIN-01: Dashboard menampilkan nama user yang login', (tester) async {
    // Mock getEvents to return some events
    when(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: any(named: 'status'),
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult(tEventList())));

    await tester.pumpApp(const AdminDashboardPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.text('Admin Test'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });

  testWidgets('IT-ADMIN-02: Dashboard menampilkan statistik kegiatan', (tester) async {
    final now = DateTime.now();
    final events = [
      // 1 event this week, status published (completed is not counted as incomplete)
      tEvent(
        id: '1',
        title: 'Event A',
        status: EventStatus.published,
        sessions: [tSession(startTime: now, endTime: now.add(const Duration(hours: 1)))],
      ),
      // 1 event this month, status draft (counts as incomplete)
      tEvent(
        id: '2',
        title: 'Event B',
        status: EventStatus.draft,
        sessions: [tSession(startTime: now, endTime: now.add(const Duration(hours: 1)))],
      ),
    ];

    when(
      () => mocks.eventRepository.getEvents(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        status: any(named: 'status'),
        type: any(named: 'type'),
        search: any(named: 'search'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => Right(tPaginatedResult(events)));

    await tester.pumpApp(const AdminDashboardPage(), overrides: overrides);
    await tester.pumpAndSettle();

    // Verify stats cards are rendered (4 cards total)
    expect(find.byType(DashboardCard), findsNWidgets(4));
  });
}
