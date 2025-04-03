part of 'authority_cubit.dart';

@override
abstract class AuthorityState {}

class AuthorityInitial extends AuthorityState {}

class AuthorityLoading extends AuthorityState {}

class AuthorityRequestDone extends AuthorityState {
  AuthorityRequestDone(this.data);
  final List<UserRequest> data;
}

class LeaderboardState extends AuthorityState {

  final List<LeaderboardUser> users;
  LeaderboardState(this.users);
}

class AuthoritySuccess extends AuthorityState {}

class AuthorityError extends AuthorityState {}