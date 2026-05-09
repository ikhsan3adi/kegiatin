import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel implements User {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String displayName,
    required UserRole role,
    String? npa,
    String? cabang,
    String? photoUrl,
    @Default(false) bool emailVerified,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

extension UserX on User {
  UserModel toModel() => UserModel(
    id: id,
    email: email,
    displayName: displayName,
    role: role,
    npa: npa,
    cabang: cabang,
    photoUrl: photoUrl,
    emailVerified: emailVerified,
    createdAt: createdAt,
  );
}
