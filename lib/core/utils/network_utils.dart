// core/utils/network_utils.dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> isConnected() async {
    /*
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
    */
    // final connectivityResult = await Connectivity().checkConnectivity();
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }


  // static Stream<ConnectivityResult> get connectivityStream {
  //   return Connectivity().onConnectivityChanged;
  // }

  static Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
}
