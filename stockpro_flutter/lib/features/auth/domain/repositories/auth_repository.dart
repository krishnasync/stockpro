import '../../../../core/utils/result.dart';
import '../entities/app_user_entity.dart';

/// Abstract contract. The domain layer (and presentation, via this
/// contract) never imports supabase_flutter directly — only
/// AuthRepositoryImpl in the data layer does. This is what makes the
/// backend swappable and the ViewModel unit-testable with a fake.
abstract interface class AuthRepository {
  Stream<AppUserEntity?> authStateChanges();

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

  AppUserEntity? get currentUser;
}
