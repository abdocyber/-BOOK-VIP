import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  NetworkService._();

  static Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Stream<bool> get onlineChanges => Connectivity()
      .onConnectivityChanged
      .map((result) => !result.contains(ConnectivityResult.none))
      .distinct();
}
