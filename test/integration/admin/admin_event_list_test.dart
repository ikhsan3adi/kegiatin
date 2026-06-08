import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/pages/admin/admin_event_page.dart';
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
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: tAdminUser())),
    ];

    // Mock basic Hive and SharedPreferences responses
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);
  });

  testWidgets('IT-ADMIN-04: Event list menampilkan daftar kegiatan', (tester) async {
    final events = [
      tEvent(id: '1', title: 'Kegiatan A', status: EventStatus.ongoing),
      tEvent(id: '2', title: 'Kegiatan B', status: EventStatus.ongoing),
      tEvent(id: '3', title: 'Kegiatan C', status: EventStatus.ongoing),
    ];

    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult(events)));

    await tester.pumpApp(const AdminEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.byType(EventListCard), findsNWidgets(3));
    expect(find.text('Kegiatan A'), findsOneWidget);
    expect(find.text('Kegiatan B'), findsOneWidget);
    expect(find.text('Kegiatan C'), findsOneWidget);
  });

  testWidgets('IT-ADMIN-05: Event list — filter chip \'Draft\' memfilter event', (tester) async {
    // Initial ONGOING fetch stub
    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult([])));

    // DRAFT fetch stub
    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.draft,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult([])));

    await tester.pumpApp(const AdminEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    // Tap Draft filter chip
    final draftChip = find.text('Draft');
    await tester.tap(draftChip);
    await tester.pumpAndSettle();

    // Verify DRAFT filter was passed to repository
    verify(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.draft,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).called(greaterThanOrEqualTo(1));
  });

  testWidgets('IT-ADMIN-06: Event list — search memfilter event (debounce)', (tester) async {
    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult([])));

    await tester.pumpApp(const AdminEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    // Enter query 'Kajian' in search field
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Kajian');
    
    // Pump immediately — should not trigger call because of 500ms debounce
    await tester.pump();
    verifyNever(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: 'Kajian',
      forceRefresh: any(named: 'forceRefresh'),
    ));

    // Wait for 500ms debounce + fetch settling
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    verify(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: 'Kajian',
      forceRefresh: any(named: 'forceRefresh'),
    )).called(greaterThanOrEqualTo(1));
  });

  testWidgets('IT-ADMIN-07: Event list kosong menampilkan empty state', (tester) async {
    when(() => mocks.eventRepository.getEvents(
      page: any(named: 'page'),
      limit: any(named: 'limit'),
      status: EventStatus.ongoing,
      type: any(named: 'type'),
      search: any(named: 'search'),
      forceRefresh: any(named: 'forceRefresh'),
    )).thenAnswer((_) async => Right(tPaginatedResult([])));

    await tester.pumpApp(const AdminEventPage(), overrides: overrides);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kegiatan'), findsOneWidget);
  });

}
