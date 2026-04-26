import 'package:hive_ce/hive.dart';
import 'package:kegiatin/core/constants/db_constants.dart';
import 'package:kegiatin/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Box<dynamic> authBox;

  AuthLocalDataSourceImpl({required this.sharedPreferences, required this.authBox});

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await sharedPreferences.setString(DbConstants.tokenKey, accessToken);
    await sharedPreferences.setString(DbConstants.refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> getAccessToken() async => sharedPreferences.getString(DbConstants.tokenKey);

  @override
  Future<String?> getRefreshToken() async =>
      sharedPreferences.getString(DbConstants.refreshTokenKey);

  @override
  Future<void> saveUser(UserModel user) => authBox.put(DbConstants.cachedUserKey, user.toJson());

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = authBox.get(DbConstants.cachedUserKey);
    if (raw == null) return null;

    final json = Map<String, dynamic>.from(raw as Map);
    return UserModel.fromJson(json);
  }

  @override
  Future<void> clearAll() async {
    await sharedPreferences.remove(DbConstants.tokenKey);
    await sharedPreferences.remove(DbConstants.refreshTokenKey);
    await authBox.delete(DbConstants.cachedUserKey);
  }
}
