import 'package:kegiatin/core/errors/failures.dart';
import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    final localDS = ref.read(authLocalDataSourceProvider);

    final results = await Future.wait([
      localDS.getAccessToken(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    final accessToken = results[0] as String?;

    if (accessToken == null) return null;

    // Token exists — resolve user from network or cache.
    final result = await ref.read(getCurrentUserUseCaseProvider).call(NoInput.instance);
    return result.fold((failure) async {
      if (failure is AuthFailure) {
        // Token definitively rejected by server — force re-login.
        await _clearAllCaches();
        return null;
      }
      // Network/server error — stay logged in with cached user.
      final cached = await localDS.getCachedUser();
      return cached;
    }, (user) => user);
  }

  Future<void> _clearAllCaches() async {
    await ref.read(authLocalDataSourceProvider).clearAll();
    await ref.read(eventLocalDataSourceProvider).clearAll();
    await ref.read(rsvpLocalDataSourceProvider).clearAll();
    await ref.read(attendanceLocalDataSourceProvider).clearAll();
    await ref.read(archiveLocalDataSourceProvider).clearAll();
    await ref.read(historyLocalDataSourceProvider).clearAll();
  }

  Future<String?> login(LoginInput input) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider).call(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (authResponse) {
        state = AsyncData(authResponse.user);
        return null;
      },
    );
  }

  Future<String?> register(RegisterInput input) async {
    state = const AsyncLoading();
    final result = await ref.read(registerUseCaseProvider).call(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(NoInput.instance);
    await _clearAllCaches();
    state = const AsyncData(null);
  }
}
