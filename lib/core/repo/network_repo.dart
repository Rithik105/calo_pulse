import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkRepo {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
