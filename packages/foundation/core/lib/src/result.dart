import 'errors/app_failure.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppFailure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? getOrNull() => isSuccess ? (this as Success<T>).data : null;
  AppFailure? exceptionOrNull() =>
      isFailure ? (this as FailureResult<T>).failure : null;

  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppFailure failure) onFailure,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as FailureResult<T>).failure);
    }
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class FailureResult<T> extends Result<T> {
  final AppFailure failure;
  const FailureResult(this.failure);
}
