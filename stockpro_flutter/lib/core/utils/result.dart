/// A `Result<T>` type so repositories never throw across the
/// domain/presentation boundary. ViewModels pattern-match on this instead
/// of wrapping every repository call in try/catch — keeps error handling
/// consistent app-wide and makes "show an error state" impossible to forget.
library;

import 'failures.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failed<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Failed<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}
