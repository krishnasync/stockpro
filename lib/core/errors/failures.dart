/// Base failure type. Repositories return `Result<T>` (below), never throw
/// raw exceptions up to the presentation layer — this keeps error handling
/// explicit and forces every screen to consider the failure case.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(
      [super.message = 'You do not have permission to do this.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data unavailable.']);
}

/// Lightweight Either-style result, avoids pulling in dartz just for this.
/// Usage:
///   Result<Product> result = await repo.getProduct(id);
///   result.when(
///     success: (product) => ...,
///     failure: (f) => ...,
///   );
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = Error<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Error<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
