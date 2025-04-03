part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthDone extends AuthState {}
class AuthInvalid extends AuthState {}
class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}