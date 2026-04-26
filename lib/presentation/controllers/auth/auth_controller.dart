import 'package:kegiatin/domain/entities/login_input.dart';
import 'package:kegiatin/domain/entities/register_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/usecases/base_usecase.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// State untuk auth — null berarti belum login / sedang loading.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).call(NoInput.instance);
    return result.fold((failure) => null, (user) => user);
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
      (authResponse) {
        state = AsyncData(authResponse.user);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(NoInput.instance);
    state = const AsyncData(null);
  }
}
