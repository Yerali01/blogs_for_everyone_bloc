part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(
      this.user); //here is the const, because of this line: const AuthState();
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(
    this.message,
  ); //here is the const, because of this line: const AuthState();
}
