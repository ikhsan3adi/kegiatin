import 'package:kegiatin/domain/entities/update_profile_input.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  FutureOr<void> build() {}

  /// Perbarui profil pengguna dan sinkronkan state auth.
  ///
  /// Mengembalikan `null` jika berhasil, atau pesan error jika gagal.
  Future<String?> updateProfile(UpdateProfileInput input) async {
    state = const AsyncLoading();
    final result = await ref.read(updateProfileUseCaseProvider).call(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = const AsyncData(null);
        _refreshAuthState(user);
        return null;
      },
    );
  }

  /// Upload foto profil lalu kembalikan URL-nya.
  ///
  /// Mengembalikan URL string jika berhasil, atau `null` jika gagal.
  Future<String?> uploadPhoto(String filePath) async {
    try {
      final url = await ref.read(uploadsRemoteDataSourceProvider).uploadImage(filePath);
      return url;
    } on Exception {
      return null;
    }
  }

  /// Paksa auth controller memuat ulang user terbaru dari server.
  void _refreshAuthState(User updatedUser) {
    ref.invalidate(authControllerProvider);
  }
}
