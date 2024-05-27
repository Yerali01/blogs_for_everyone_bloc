import 'package:blogs_for_everyone/core/error/exceptions.dart';
import 'package:blogs_for_everyone/core/error/failures.dart';
import 'package:blogs_for_everyone/core/network/connection_checker.dart';
import 'package:blogs_for_everyone/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blogs_for_everyone/core/common/entities/user.dart';
import 'package:blogs_for_everyone/features/auth/data/models/user_model.dart';
import 'package:blogs_for_everyone/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImplementation(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        //if there  is no internet connection we will try to log in user offline, because it is possible that he has an account. Also, this line: Session? get currentUserSession => supabaseClient.auth.currentSession; in the AuthRemoteDataSourceImplementation means that it is not Future. So, it does not require internet connection. We will try to get UserModel from Session class.If user does not have an account, we will not  return anything
        final session = remoteDataSource.currentUserSession;

        if (session == null) {
          return left(Failure("user is not logged in"));
        }

        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? "",
            name:
                "", // name does not matter, because the most important thing is id
          ),
        );
      }

      final user = await remoteDataSource.getCurrentUserData();

      if (user == null) {
        return left(Failure("user is not logged in"));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.logInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure("No internet connection"));
      }

      final user = await fn();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
