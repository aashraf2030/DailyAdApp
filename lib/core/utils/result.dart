import '../exceptions/app_exceptions.dart';

/// Result pattern for better error handling
/// Instead of throwing exceptions, we return Result<T>
sealed class Result<T> {
  const Result();
}

/// Success result with data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Failure result with exception
class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure(exception: $exception)';
}

/// Extensions for easier result handling
extension ResultExtensions<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data or null
  T? get dataOrNull {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }

  /// Get exception or null
  AppException? get exceptionOrNull {
    return switch (this) {
      Success() => null,
      Failure(exception: final exception) => exception,
    };
  }

  /// Execute function based on result
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(exception: final exception) => failure(exception),
    };
  }

  /// Execute function only on success
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  /// Execute async function only on success
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(data: final data) => Success(await transform(data)),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  /// Chain results
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  /// Get data or throw exception
  T getOrThrow() {
    return switch (this) {
      Success(data: final data) => data,
      Failure(exception: final exception) => throw exception,
    };
  }

  /// Get data or default value
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue,
    };
  }

  /// Get data or compute default value
  T getOrElseCompute(T Function() defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue(),
    };
  }
}

