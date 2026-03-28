import '../exceptions/app_exceptions.dart';



sealed class Result<T> {
  const Result();
}


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


extension ResultExtensions<T> on Result<T> {
  
  bool get isSuccess => this is Success<T>;

  
  bool get isFailure => this is Failure<T>;

  
  T? get dataOrNull {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }

  
  AppException? get exceptionOrNull {
    return switch (this) {
      Success() => null,
      Failure(exception: final exception) => exception,
    };
  }

  
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(exception: final exception) => failure(exception),
    };
  }

  
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(data: final data) => Success(await transform(data)),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(exception: final exception) => Failure(exception),
    };
  }

  
  T getOrThrow() {
    return switch (this) {
      Success(data: final data) => data,
      Failure(exception: final exception) => throw exception,
    };
  }

  
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue,
    };
  }

  
  T getOrElseCompute(T Function() defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue(),
    };
  }
}

