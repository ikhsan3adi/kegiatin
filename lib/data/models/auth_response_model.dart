import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:kegiatin/domain/entities/auth_response.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

@freezed
abstract class AuthResponseModel with _$AuthResponseModel implements AuthResponse {
  const AuthResponseModel._();

  const factory AuthResponseModel({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
