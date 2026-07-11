import '../../../../core/errors/failures.dart';
import '../entities/app_user_entity.dart';

/// The domain layer defines WHAT auth operations exist. It knows nothing
/// about Supabase — that's the data layer's job (auth_repository_impl.dart).
/// This is what makes it possible to unit-test ViewModels by providing a
/// fake implementation of this interface, with no network involved.
abstract class AuthRepository {
  Future<Result<AppUserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> sendOtp({required String phone});

  Future<Result<AppUserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<Result<void>> sendPasswordReset({required String email});

  Future<Result<void>> signOut();

  /// Null if not authenticated.
  Future<AppUserEntity?> getCurrentUser();
}
