import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/domain/enums/event_status.dart';
import 'package:kegiatin/domain/enums/event_type.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(EventStatus.draft);
    registerFallbackValue(EventType.single);
    registerFallbackValue(tCreateEventInput());
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

  testWidgets('IT-CREATE-01: Create event page renders correctly', (tester) async {
    await tester.pumpRouterApp(overrides: overrides, initialLocation: '/admin/create-event');
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kegiatan'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Simpan Kegiatan'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
