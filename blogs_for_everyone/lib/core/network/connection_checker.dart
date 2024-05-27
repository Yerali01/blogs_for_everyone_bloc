import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImplementation implements ConnectionChecker {
  final InternetConnection internetConnection;
  ConnectionCheckerImplementation(this.internetConnection);

  @override
  Future<bool> get isConnected async {
    return await internetConnection.hasInternetAccess;
  }
}
