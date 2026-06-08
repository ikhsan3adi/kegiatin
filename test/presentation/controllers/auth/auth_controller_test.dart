import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_definitions.dart';
import '../../../helpers/test_fixtures.dart';
import '../../../helpers/fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthLocalDataSource mockAuthLocalDS;
  late MockEventLocalDataSource mockEventLocalDS;
  late MockRsvpLocalDataSource mockRsvpLocalDS;
  late MockAttendanceLocalDataSource mockAttendanceLocalDS;
  late MockArchiveLocalDataSource mockArchiveLocalDS;
  late MockHistoryLocalDataSource mockHistoryLocalDS;

  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockGoogleLoginUseCase mockGoogleLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUpAll(() {
    dotenv.testLoad(fileInput: 'GOOGLE_SERVER_CLIENT_ID=test-client-id');
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    mockAuthLocalDS = MockAuthLocalDataSource();
    mockEventLocalDS = MockEventLocalDataSource();
    mockRsvpLocalDS = MockRsvpLocalDataSource();
    mockAttendanceLocalDS = MockAttendanceLocalDataSource();
    mockArchiveLocalDS = MockArchiveLocalDataSource();
    mockHistoryLocalDS = MockHistoryLocalDataSource();

    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockLoginUseCase = MockLoginUseCase();
    mockGoogleLoginUseCase = MockGoogleLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authLocalDataSourceProvider.overrideWithValue(mockAuthLocalDS),
        eventLocalDataSourceProvider.overrideWithValue(mockEventLocalDS),
        rsvpLocalDataSourceProvider.overrideWithValue(mockRsvpLocalDS),
        attendanceLocalDataSourceProvider.overrideWithValue(mockAttendanceLocalDS),
        archiveLocalDataSourceProvider.overrideWithValue(mockArchiveLocalDS),
        historyLocalDataSourceProvider.overrideWithValue(mockHistoryLocalDS),
        getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUserUseCase),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        googleLoginUseCaseProvider.overrideWithValue(mockGoogleLoginUseCase),
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthController - build', () {
    test('returns null when no access token exists', () {
      fakeAsync((async) {
        when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);

        final container = createContainer();
        container.read(authControllerProvider.future);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        final state = container.read(authControllerProvider);
        expect(state.value, isNull);
      });
    });

    test('returns User when access token exists and getCurrentUser succeeds', () {
      fakeAsync((async) {
        final user = tUser();
        when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => 'token');
        when(() => mockGetCurrentUserUseCase.call(any())).thenAnswer((_) async => Right(user));

        final container = createContainer();
        container.read(authControllerProvider.future);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        final state = container.read(authControllerProvider);
        expect(state.value, equals(user));
      });
    });

    test('clears cache and returns null when getCurrentUser fails with AuthFailure', () {
      fakeAsync((async) {
        when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => 'token');
        when(() => mockGetCurrentUserUseCase.call(any()))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid Token')));

        when(() => mockAuthLocalDS.clearAll()).thenAnswer((_) async {});
        when(() => mockEventLocalDS.clearAll()).thenAnswer((_) async {});
        when(() => mockRsvpLocalDS.clearAll()).thenAnswer((_) async {});
        when(() => mockAttendanceLocalDS.clearAll()).thenAnswer((_) async {});
        when(() => mockArchiveLocalDS.clearAll()).thenAnswer((_) async {});
        when(() => mockHistoryLocalDS.clearAll()).thenAnswer((_) async {});

        final container = createContainer();
        container.read(authControllerProvider.future);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        final state = container.read(authControllerProvider);
        expect(state.value, isNull);

        verify(() => mockAuthLocalDS.clearAll()).called(1);
        verify(() => mockEventLocalDS.clearAll()).called(1);
        verify(() => mockRsvpLocalDS.clearAll()).called(1);
        verify(() => mockAttendanceLocalDS.clearAll()).called(1);
        verify(() => mockArchiveLocalDS.clearAll()).called(1);
        verify(() => mockHistoryLocalDS.clearAll()).called(1);
      });
    });

    test('returns cached User when getCurrentUser fails with other Failure', () {
      fakeAsync((async) {
        final user = tUser();
        final userModel = UserModel(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          role: user.role,
          npa: user.npa,
          cabang: user.cabang,
          photoUrl: user.photoUrl,
          emailVerified: user.emailVerified,
          createdAt: user.createdAt,
        );
        when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => 'token');
        when(() => mockGetCurrentUserUseCase.call(any()))
            .thenAnswer((_) async => const Left(NetworkFailure('Offline')));
        when(() => mockAuthLocalDS.getCachedUser()).thenAnswer((_) async => userModel);

        final container = createContainer();
        container.read(authControllerProvider.future);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        final state = container.read(authControllerProvider);
        expect(state.value?.id, equals(user.id));
      });
    });
  });

  group('AuthController - login', () {
    test('sets state to AsyncData(user) on success', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();

      // Let build() finish
      await container.read(authControllerProvider.future);

      final user = tUser();
      when(() => mockLoginUseCase.call(any())).thenAnswer((_) async => Right(tAuthResponse(user: user)));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.login(tLoginInput());

      expect(error, isNull);
      expect(container.read(authControllerProvider).value, equals(user));
    });

    test('sets state to AsyncError on failure', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();

      // Let build() finish
      await container.read(authControllerProvider.future);

      when(() => mockLoginUseCase.call(any()))
          .thenAnswer((_) async => const Left(AuthFailure('Wrong credentials')));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.login(tLoginInput());

      expect(error, 'Wrong credentials');
      expect(container.read(authControllerProvider).hasError, true);
    });
  });

  group('AuthController - register', () {
    test('sets state to null on success', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();
      await container.read(authControllerProvider.future);

      final user = tUser();
      when(() => mockRegisterUseCase.call(any())).thenAnswer((_) async => Right(user));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.register(tRegisterInput());

      expect(error, isNull);
      expect(container.read(authControllerProvider).value, isNull);
    });

    test('sets state to AsyncError on failure', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();
      await container.read(authControllerProvider.future);

      when(() => mockRegisterUseCase.call(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Email already exists')));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.register(tRegisterInput());

      expect(error, 'Email already exists');
      expect(container.read(authControllerProvider).hasError, true);
    });
  });

  group('AuthController - logout', () {
    test('calls logoutUseCase, clears local storage, and sets state to null', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => 'token');
      final user = tUser();
      when(() => mockGetCurrentUserUseCase.call(any())).thenAnswer((_) async => Right(user));

      final container = createContainer();
      await container.read(authControllerProvider.future);

      expect(container.read(authControllerProvider).value, equals(user));

      when(() => mockLogoutUseCase.call(any())).thenAnswer((_) async => const Right(null));
      when(() => mockAuthLocalDS.clearAll()).thenAnswer((_) async {});
      when(() => mockEventLocalDS.clearAll()).thenAnswer((_) async {});
      when(() => mockRsvpLocalDS.clearAll()).thenAnswer((_) async {});
      when(() => mockAttendanceLocalDS.clearAll()).thenAnswer((_) async {});
      when(() => mockArchiveLocalDS.clearAll()).thenAnswer((_) async {});
      when(() => mockHistoryLocalDS.clearAll()).thenAnswer((_) async {});

      final controller = container.read(authControllerProvider.notifier);
      await controller.logout();

      expect(container.read(authControllerProvider).value, isNull);
      verify(() => mockLogoutUseCase.call(any())).called(1);
      verify(() => mockAuthLocalDS.clearAll()).called(1);
    });
  });

  group('AuthController - loginWithGoogle', () {
    const channel = MethodChannel('plugins.flutter.io/google_sign_in');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'init') return null;
          if (methodCall.method == 'signIn') {
            return {
              'displayName': 'Google User',
              'email': 'google@example.com',
              'id': 'google-id',
              'photoUrl': 'url',
              'serverAuthCode': 'code',
            };
          }
          if (methodCall.method == 'getTokens') {
            return {
              'idToken': 'mock-id-token',
              'accessToken': 'mock-access-token',
            };
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });

    test('sets state to AsyncData(user) on success', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();
      await container.read(authControllerProvider.future);

      final user = tUser();
      when(() => mockGoogleLoginUseCase.call(any())).thenAnswer((_) async => Right(tAuthResponse(user: user)));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.loginWithGoogle();

      if (error != null) {
        final state = container.read(authControllerProvider);
        print('AuthController state: $state');
        if (state is AsyncError) {
          print('AuthController error: ${state.error}');
          print('AuthController stack: ${state.stackTrace}');
        }
      }

      expect(error, isNull);
      expect(container.read(authControllerProvider).value, equals(user));
      verify(() => mockGoogleLoginUseCase.call('mock-id-token')).called(1);
    });

    test('sets state to AsyncError on failure', () async {
      when(() => mockAuthLocalDS.getAccessToken()).thenAnswer((_) async => null);
      final container = createContainer();
      await container.read(authControllerProvider.future);

      when(() => mockGoogleLoginUseCase.call(any()))
          .thenAnswer((_) async => const Left(AuthFailure('Google Login Failed')));

      final controller = container.read(authControllerProvider.notifier);
      final error = await controller.loginWithGoogle();

      expect(error, 'Google Login Failed');
      expect(container.read(authControllerProvider).hasError, true);
    });
  });
}
