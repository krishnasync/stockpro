import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user_entity.dart';

/// Only file in the whole `auth` feature that imports supabase_flutter.
/// Everything above this layer (repository, providers, screens) talks in
/// terms of AppUserEntity, never raw Supabase types.
class AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSource(this._client);

  Future<AppUserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed — no user returned.');
    }
    return _fetchFullProfile(user.id);
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> sendOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AppUserEntity> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('OTP verification failed.');
    }
    return _fetchFullProfile(user.id);
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AppUserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchFullProfile(user.id);
  }

  /// Joins app_users -> user_roles -> roles -> role_permissions -> permissions
  /// in one round trip so the app has the full permission set on login,
  /// rather than querying permissions repeatedly per-screen.
  Future<AppUserEntity> _fetchFullProfile(String authUserId) async {
    final row = await _client
        .from('app_users')
        .select('''
          id, company_id, full_name, email, phone, avatar_url,
          user_roles (
            roles (
              name,
              role_permissions ( permissions ( code ) )
            )
          )
        ''')
        .eq('id', authUserId)
        .single();

    final roleNames = <String>{};
    final permissionCodes = <String>{};

    for (final ur in (row['user_roles'] as List? ?? [])) {
      final role = ur['roles'];
      if (role == null) continue;
      roleNames.add(role['name'] as String);
      for (final rp in (role['role_permissions'] as List? ?? [])) {
        final code = rp['permissions']?['code'];
        if (code != null) permissionCodes.add(code as String);
      }
    }

    return AppUserEntity(
      id: row['id'] as String,
      companyId: row['company_id'] as String,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      phone: row['phone'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      roleNames: roleNames.toList(),
      permissionCodes: permissionCodes.toList(),
    );
  }
}
