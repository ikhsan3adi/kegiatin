import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(tUpdateProfileInput());
  });

  late TestAppMocks mocks;
  late List<Override> overrides;

  setUp(() {
    mocks = TestAppMocks();

    // Stub local storage for logged-in user state
    when(() => mocks.sharedPreferences.getString(any())).thenReturn('token');
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(true);
    when(() => mocks.authBox.get(any())).thenReturn(null);

    final memberUser = tUser(displayName: 'Original Name');

    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: memberUser)),
    ];
  });

  testWidgets('IT-PROF-01: Edit profile — update nama berhasil', (tester) async {
    final updatedUser = tUser(displayName: 'Updated Name');
    when(
      () => mocks.profileRepository.updateProfile(any()),
    ).thenAnswer((_) async => Right(updatedUser));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/peserta');

    // Go to edit profile route
    router.go('/peserta/edit-profile');
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Nama Tampilan');
    expect(nameField, findsOneWidget);

    // Clear and enter new text
    await tester.enterText(nameField, 'Updated Name');

    // Tap Save Changes
    final saveButton = find.widgetWithText(FilledButton, 'Simpan Perubahan');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(() => mocks.profileRepository.updateProfile(any())).called(1);
    expect(find.text('Mengerti'), findsOneWidget);
    expect(find.text('Profil berhasil diperbarui'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    // Should navigate back / pop
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/peserta');
  });

  testWidgets('IT-PROF-02: Edit profile — validasi nama kosong', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/peserta');

    router.go('/peserta/edit-profile');
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Nama Tampilan');
    await tester.enterText(nameField, '');

    final saveButton = find.widgetWithText(FilledButton, 'Simpan Perubahan');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    verifyNever(() => mocks.profileRepository.updateProfile(any()));
  });
}
