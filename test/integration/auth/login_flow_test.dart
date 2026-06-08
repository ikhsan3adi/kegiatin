import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/core/constants/db_constants.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import 'package:kegiatin/presentation/pages/login_page.dart';
import 'package:kegiatin/presentation/pages/register_page.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
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

  testWidgets('IT-AUTH-01: Login berhasil sebagai Admin → redirect ke /admin', (tester) async {
    final adminUser = tAdminUser();
    final authResp = tAuthResponse(user: adminUser);

    when(() => mocks.authRepository.login(any(), any()))
        .thenAnswer((_) async => Right(authResp));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(emailField, 'admin@test.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    verify(() => mocks.authRepository.login('admin@test.com', 'password123')).called(1);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/admin');
  });

  testWidgets('IT-AUTH-02: Login berhasil sebagai Member → redirect ke /peserta', (tester) async {
    final memberUser = tMemberUser();
    final authResp = tAuthResponse(user: memberUser);

    when(() => mocks.authRepository.login(any(), any()))
        .thenAnswer((_) async => Right(authResp));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(emailField, 'member@test.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    verify(() => mocks.authRepository.login('member@test.com', 'password123')).called(1);
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/peserta');
  });

  testWidgets('IT-AUTH-03: Login gagal — credential salah', (tester) async {
    when(() => mocks.authRepository.login(any(), any()))
        .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(emailField, 'wrong@test.com');
    await tester.enterText(passwordField, 'wrongpassword');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    verify(() => mocks.authRepository.login('wrong@test.com', 'wrongpassword')).called(1);
    expect(find.text('Mengerti'), findsOneWidget);
    expect(find.text('Invalid credentials'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('IT-AUTH-04: Login — validasi form: email kosong', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(passwordField, '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    verifyNever(() => mocks.authRepository.login(any(), any()));
  });

  testWidgets('IT-AUTH-05: Login — validasi form: password < 6 karakter', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(emailField, 'test@test.com');
    await tester.enterText(passwordField, '123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Minimal 6 karakter'), findsOneWidget);
    verifyNever(() => mocks.authRepository.login(any(), any()));
  });

  testWidgets('IT-AUTH-06: Login — tombol disabled saat loading', (tester) async {
    // We mock login returning a delay so it stays in loading state
    when(() => mocks.authRepository.login(any(), any()))
        .thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 2));
          return const Left(AuthFailure('Timeout'));
        });

    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(FilledButton, 'LOGIN');

    await tester.enterText(emailField, 'test@test.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);
    
    // Pump a frame immediately (no delay) to assert loading state
    await tester.pump();

    // The login button should be disabled (onPressed should be null)
    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(filledButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the delayed future complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Clean up SnackBar auto-dismiss timer
    expect(find.text('Mengerti'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
  });
  testWidgets('IT-AUTH-07: Login — toggle password visibility', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final passwordTextField = tester.widget<TextField>(find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    ));

    // Initially obscured
    expect(passwordTextField.obscureText, isTrue);

    // Find visibility icon button and tap it
    final visibilityToggle = find.descendant(
      of: passwordField,
      matching: find.byType(IconButton),
    );
    await tester.tap(visibilityToggle);
    await tester.pumpAndSettle();

    // Obscure text should now be false
    final updatedTextField = tester.widget<TextField>(find.descendant(
      of: passwordField,
      matching: find.byType(TextField),
    ));
    expect(updatedTextField.obscureText, isFalse);
  });

  testWidgets('IT-AUTH-08: Login — navigasi ke Register page', (tester) async {
    final router = await tester.pumpRouterApp(overrides: overrides, initialLocation: '/login');

    final signUpButton = find.widgetWithText(TextButton, 'Sign Up');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/register');
  });
}
