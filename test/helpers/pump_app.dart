import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/src/internals.dart' show Override;
export 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/theme.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'mock_definitions.dart';

import 'package:kegiatin/core/router/app_router.dart';

class FakeAuthController extends AuthController {
  final User? initialUser;
  final bool simulateLoading;

  FakeAuthController({this.initialUser, this.simulateLoading = false});

  @override
  FutureOr<User?> build() async {
    if (simulateLoading) {
      final completer = Completer<User?>();
      return completer.future;
    }
    return initialUser;
  }
}

/// Class to hold references to all mocks used in integration tests.
class TestAppMocks {
  final authBox = MockBox<dynamic>();
  final rsvpBox = MockBox<dynamic>();
  final eventCacheBox = MockBox<dynamic>();
  final attendanceBox = MockBox<dynamic>();
  final archiveBox = MockBox<dynamic>();
  final profileBox = MockBox<dynamic>();
  final sharedPreferences = MockSharedPreferences();
  final networkInfo = MockNetworkInfo();

  final authRepository = MockAuthRepository();
  final eventRepository = MockEventRepository();
  final rsvpRepository = MockRsvpRepository();
  final attendanceRepository = MockAttendanceRepository();
  final sessionRepository = MockSessionRepository();
  final archiveRepository = MockArchiveRepository();
  final profileRepository = MockProfileRepository();
  final pcdRepository = MockPcdRepository();
  final userRepository = MockUserRepository();

  TestAppMocks() {
    // Stub all Hive boxes to return empty iterables by default
    when(() => authBox.values).thenReturn([]);
    when(() => rsvpBox.values).thenReturn([]);
    when(() => eventCacheBox.values).thenReturn([]);
    when(() => attendanceBox.values).thenReturn([]);
    when(() => archiveBox.values).thenReturn([]);
    when(() => profileBox.values).thenReturn([]);

    // Stub network info
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
  }
}

List<Override> createProviderOverrides(TestAppMocks mocks) {
  return [
    sharedPreferencesProvider.overrideWithValue(mocks.sharedPreferences),
    authBoxProvider.overrideWithValue(mocks.authBox),
    rsvpBoxProvider.overrideWithValue(mocks.rsvpBox),
    eventCacheBoxProvider.overrideWithValue(mocks.eventCacheBox),
    attendanceBoxProvider.overrideWithValue(mocks.attendanceBox),
    archiveBoxProvider.overrideWithValue(mocks.archiveBox),
    profileBoxProvider.overrideWithValue(mocks.profileBox),
    networkInfoProvider.overrideWithValue(mocks.networkInfo),

    authRepositoryProvider.overrideWithValue(mocks.authRepository),
    eventRepositoryProvider.overrideWithValue(mocks.eventRepository),
    rsvpRepositoryProvider.overrideWithValue(mocks.rsvpRepository),
    attendanceRepositoryProvider.overrideWithValue(mocks.attendanceRepository),
    sessionRepositoryProvider.overrideWithValue(mocks.sessionRepository),
    archiveRepositoryProvider.overrideWithValue(mocks.archiveRepository),
    profileRepositoryProvider.overrideWithValue(mocks.profileRepository),
    pcdRepositoryProvider.overrideWithValue(mocks.pcdRepository),
    userRepositoryProvider.overrideWithValue(mocks.userRepository),
  ];
}

extension PumpApp on WidgetTester {
  /// Pumps a widget inside a MaterialApp with custom overrides.
  Future<void> pumpApp(
    Widget widget, {
    required List<Override> overrides,
  }) async {
    view.physicalSize = const Size(1080, 1920);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: const MaterialTheme(TextTheme()).light(),
          home: Scaffold(body: widget),
        ),
      ),
    );
    await pump();
  }

  /// Pumps GoRouter inside a MaterialApp.router with custom overrides.
  Future<GoRouter> pumpRouterApp({
    required List<Override> overrides,
    String initialLocation = '/',
  }) async {
    final container = ProviderContainer(overrides: overrides);
    final router = container.read(appRouterProvider);

    view.physicalSize = const Size(1080, 1920);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: const MaterialTheme(TextTheme()).light(),
          routerConfig: router,
        ),
      ),
    );
    await pump();

    // Advance clock to let SplashPage timer resolve and clean up its pending timer
    await pump(const Duration(seconds: 3));

    if (initialLocation != '/') {
      router.go(initialLocation);
      await pumpAndSettle();
    }

    return router;
  }
}
