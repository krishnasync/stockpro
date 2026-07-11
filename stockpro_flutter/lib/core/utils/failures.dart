/// Domain-level failure types. Data-layer exceptions (PostgrestException,
/// AuthException, SocketException, etc.) get caught in the repository
/// implementation and mapped to one of these — the domain layer never
/// sees a raw Supabase exception type.
library;

sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission to do this.']);
}
