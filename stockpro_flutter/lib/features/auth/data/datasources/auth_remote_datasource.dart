import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user_model.dart';

/// Talks to Supabase directly. This is the ONLY file in the auth feature
/// that imports supabase_flutter's auth/postgrest types — everything else
/// depends on the abstractions above it.
class AuthRemoteDataSource {
  final SupabaseClient _client;
  const AuthRemoteDataSource(this._client);

  Stream<AppUserModel?> authStateChanges() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return _fetchProfile(user.id);
    });
  }

  Future<AppUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final userId = response.user!.id;
    return _fetchProfile(userId);
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> sendOtp({required String phone}) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AppUserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    return _fetchProfile(response.user!.id);
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Joins app_users -> user_roles -> roles per the schema in
  /// 02_database_schema.sql so we get the user's role names in one query.
  Future<AppUserModel> _fetchProfile(String userId) async {
    final row = await _client
        .from('app_users')
        .select('*, user_roles(roles(name))')
        .eq('id', userId)
        .single();
    return AppUserModel.fromJson(row);
  }
}
