import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/presentation/pages/register_page.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(tRegisterInput());
  });

  late TestAppMocks mocks;
  late List<Override> overrides;

  setUp(() {
    mocks = TestAppMocks();
    overrides = [
      ...createProviderOverrides(mocks),
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: null)),
    ];

    // Mock basic Hive and SharedPreferences responses
    when(() => mocks.sharedPreferences.getString(any())).thenReturn(null);
    when(() => mocks.sharedPreferences.getBool(any())).thenReturn(false);
    when(() => mocks.authBox.get(any())).thenReturn(null);
    when(() => mocks.authBox.delete(any())).thenAnswer((_) async {});
    when(() => mocks.sharedPreferences.remove(any())).thenAnswer((_) async => true);
    when(() => mocks.sharedPreferences.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mocks.sharedPreferences.setBool(any(), any())).thenAnswer((_) async => true);
  });

  testWidgets('IT-REG-01: Register berhasil sebagai Umum → redirect ke Login', (tester) async {
    final memberUser = tMemberUser();
    when(() => mocks.authRepository.register(any()))
        .thenAnswer((_) async => Right(memberUser));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/register');

    final nameField = find.widgetWithText(TextFormField, 'Nama Lengkap');
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final signUpButton = find.widgetWithText(FilledButton, 'SIGN UP');

    await tester.enterText(nameField, 'Test User');
    await tester.enterText(emailField, 'test@test.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    verify(() => mocks.authRepository.register(any())).called(1);
    expect(find.text('Mengerti'), findsOneWidget);
    expect(find.text('Registrasi berhasil. Silakan masuk.'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/login');
  });

  testWidgets('IT-REG-02: Register sebagai Anggota — field NPA dan Cabang muncul', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/register');

    // Initially, NPA and Cabang should not be in the widget tree (General/Umum mode)
    expect(find.widgetWithText(TextFormField, 'NPA'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Cabang'), findsNothing);

    // Select 'Anggota' segment
    final anggotaSegment = find.text('Anggota');
    await tester.tap(anggotaSegment);
    await tester.pumpAndSettle();

    // Now, NPA and Cabang text fields should be visible
    expect(find.widgetWithText(TextFormField, 'NPA'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Cabang'), findsOneWidget);
  });

  testWidgets('IT-REG-03: Register Anggota — NPA wajib diisi', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/register');

    // Select 'Anggota' segment
    await tester.tap(find.text('Anggota'));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Nama Lengkap');
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final signUpButton = find.widgetWithText(FilledButton, 'SIGN UP');

    await tester.enterText(nameField, 'Test Member');
    await tester.enterText(emailField, 'member@test.com');
    await tester.enterText(passwordField, 'password123');
    // Leave NPA empty
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(find.text('NPA wajib diisi untuk anggota'), findsOneWidget);
    verifyNever(() => mocks.authRepository.register(any()));
  });

  testWidgets('IT-REG-04: Register gagal — server error', (tester) async {
    when(() => mocks.authRepository.register(any()))
        .thenAnswer((_) async => const Left(ServerFailure('Email already exists')));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/register');

    final nameField = find.widgetWithText(TextFormField, 'Nama Lengkap');
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final signUpButton = find.widgetWithText(FilledButton, 'SIGN UP');

    await tester.enterText(nameField, 'Test User');
    await tester.enterText(emailField, 'existing@test.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    verify(() => mocks.authRepository.register(any())).called(1);
    expect(find.text('Mengerti'), findsOneWidget);
    expect(find.text('Email already exists'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    // Should NOT redirect to login on failure
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/register');
  });

  testWidgets('IT-REG-05: Register — navigasi ke Login page', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/register');

    final loginLink = find.widgetWithText(TextButton, 'Login');
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/login');
  });
}
