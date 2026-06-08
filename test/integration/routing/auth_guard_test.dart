import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kegiatin/core/router/app_router.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late TestAppMocks mocks;
  late List<Override> baseOverrides;

  setUp(() {
    mocks = TestAppMocks();
    baseOverrides = createProviderOverrides(mocks);
  });

  testWidgets('IT-ROUTE-01: User tidak login → akses /admin → redirect ke /login', (tester) async {
    final overrides = [
      ...baseOverrides,
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: null)),
    ];

    // Build the router with overrides in scope
    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to protected admin route
    router.go('/admin');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/login');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('IT-ROUTE-02: User login Admin → akses /peserta → redirect ke /admin', (tester) async {
    final adminUser = tAdminUser();
    final overrides = [
      ...baseOverrides,
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: adminUser)),
    ];

    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try navigating to a participant route
    router.go('/peserta');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/admin');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('IT-ROUTE-03: User login Member → akses /admin → redirect ke /peserta', (tester) async {
    final memberUser = tMemberUser();
    final overrides = [
      ...baseOverrides,
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: memberUser)),
    ];

    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try navigating to an admin route
    router.go('/admin');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/peserta');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('IT-ROUTE-04: User login Admin → akses splash / → redirect ke /admin', (tester) async {
    final adminUser = tAdminUser();
    final overrides = [
      ...baseOverrides,
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: adminUser)),
    ];

    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    
    // Splash page has a timer, we need to pump 3 seconds to let it settle and navigate
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/admin');
  });

  testWidgets('IT-ROUTE-05: User login Member → akses /login → redirect ke /peserta', (tester) async {
    final memberUser = tMemberUser();
    final overrides = [
      ...baseOverrides,
      authControllerProvider.overrideWith(() => FakeAuthController(initialUser: memberUser)),
    ];

    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Try navigating to login page
    router.go('/login');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/peserta');
    await tester.pump(const Duration(seconds: 3));
  });
}
