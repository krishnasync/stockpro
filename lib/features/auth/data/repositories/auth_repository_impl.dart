import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implements the domain contract using the remote data source, and is
/// solely responsible for catching exceptions and converting them into
/// typed Failures. The ViewModel never sees a raw AuthException.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<Result<AppUserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _remote.signInWithEmail(email: email, password: password);
      return Result.success(user);
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendOtp({required String phone}) async {
    try {
      await _remote.sendOtp(phone: phone);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
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
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) async {
    try {
      await _remote.sendPasswordReset(email: email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<AppUserEntity?> getCurrentUser() => _remote.getCurrentUser();
}
