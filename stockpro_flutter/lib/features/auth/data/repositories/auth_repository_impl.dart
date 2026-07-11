import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implements the domain contract. Its whole job is: call the datasource,
/// catch Supabase-specific exceptions, and translate them into the
/// generic Failure types the rest of the app understands.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SupabaseClient _client;

  AuthRepositoryImpl(this._remote, this._client);

  @override
  Stream<AppUserEntity?> authStateChanges() => _remote.authStateChanges();

  @override
  Future<Result<AppUserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signInWithEmail(email: email, password: password);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> sendOtp({required String phone}) async {
    try {
      await _remote.sendOtp(phone: phone);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<AppUserEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final user = await _remote.verifyOtp(phone: phone, otp: otp);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) async {
    try {
      await _remote.sendPasswordReset(email: email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return const Result.success(null);
    } catch (e) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  AppUserEntity? get currentUser => null; // resolved via authStateChanges() stream instead
}
