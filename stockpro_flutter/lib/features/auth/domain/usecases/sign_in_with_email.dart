import '../../../../core/utils/result.dart';
import '../entities/app_user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use cases are optional ceremony for something this simple (it's a
/// one-line passthrough to the repository) — included here to show the
/// pattern for when a real use case has actual orchestration logic, e.g.
/// "sign in, then fetch role permissions, then log an audit entry."
class SignInWithEmail {
  final AuthRepository _repository;
  const SignInWithEmail(this._repository);

  Future<Result<AppUserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
