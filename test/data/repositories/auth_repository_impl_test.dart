import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kegiatin/core/errors/exceptions.dart';
import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/data/models/auth_response_model.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fallback_values.dart';
import '../../helpers/mock_definitions.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerUseCaseFallbackValues();
    registerRepoFallbackValues();
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('login', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login('test@example.com', 'password123');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(AuthResponse) + saves locally on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
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
      final responseModel = AuthResponseModel(
        user: userModel,
        accessToken: 'at',
        refreshToken: 'rt',
      );
      when(() => remoteDataSource.login(any(), any())).thenAnswer((_) async => responseModel);
      when(() => localDataSource.saveTokens(any(), any())).thenAnswer((_) async {});
      when(() => localDataSource.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.login('test@example.com', 'password123');

      expect(result.isRight(), true);
      verify(() => localDataSource.saveTokens('at', 'rt')).called(1);
      verify(() => localDataSource.saveUser(any())).called(1);
    });

    test('returns Left(AuthFailure) on UnauthorizedException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.login(any(), any()),
      ).thenThrow(const UnauthorizedException('Wrong credentials'));

      final result = await repository.login('test@example.com', 'wrong');

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<AuthFailure>()), (_) => fail('Expected failure'));
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.login(any(), any()),
      ).thenThrow(const ServerException('Server error', statusCode: 500));

      final result = await repository.login('test@example.com', 'password123');

      expect(result.isLeft(), true);
      result.fold((f) {
        expect(f, isA<ServerFailure>());
        expect((f as ServerFailure).statusCode, 500);
      }, (_) => fail('Expected failure'));
    });
  });

  group('register', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.register(tRegisterInput());

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(User) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
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
      when(() => remoteDataSource.register(any())).thenAnswer((_) async => userModel);

      final result = await repository.register(tRegisterInput());

      expect(result.isRight(), true);
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.register(any()),
      ).thenThrow(const ServerException('Error', statusCode: 400));

      final result = await repository.register(tRegisterInput());

      expect(result.isLeft(), true);
    });
  });

  group('getCurrentUser', () {
    test('returns cached user when offline + cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
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
      when(() => localDataSource.getCachedUser()).thenAnswer((_) async => userModel);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
    });

    test('returns NetworkFailure when offline + no cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.getCachedUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(User) + saves locally when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
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
      when(() => remoteDataSource.getCurrentUser()).thenAnswer((_) async => userModel);
      when(() => localDataSource.saveUser(any())).thenAnswer((_) async {});

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      verify(() => localDataSource.saveUser(any())).called(1);
    });

    test('fallback to cache when online + ServerException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.getCurrentUser()).thenThrow(const ServerException('Error'));
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
      when(() => localDataSource.getCachedUser()).thenAnswer((_) async => userModel);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
    });
  });

  group('refreshToken', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.refreshToken('rt');

      expect(result, const Left(NetworkFailure()));
    });

    test('returns Right(newToken) + saves locally on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.refreshToken(any())).thenAnswer((_) async => 'new-at');
      when(() => localDataSource.saveTokens(any(), any())).thenAnswer((_) async {});

      final result = await repository.refreshToken('rt');

      expect(result, const Right('new-at'));
      verify(() => localDataSource.saveTokens('new-at', 'rt')).called(1);
    });

    test('returns Left(AuthFailure) on UnauthorizedException', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.refreshToken(any())).thenThrow(const UnauthorizedException());

      final result = await repository.refreshToken('rt');

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<AuthFailure>()), (_) => fail('Expected failure'));
    });
  });

  group('logout', () {
    test('calls remote logout + clear local when online', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.logout()).thenAnswer((_) async {});
      when(() => localDataSource.clearAll()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => remoteDataSource.logout()).called(1);
      verify(() => localDataSource.clearAll()).called(1);
    });

    test('only clears local when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => localDataSource.clearAll()).thenAnswer((_) async {});

      await repository.logout();

      verifyNever(() => remoteDataSource.logout());
      verify(() => localDataSource.clearAll()).called(1);
    });
  });
}
