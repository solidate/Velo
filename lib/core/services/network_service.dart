import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Dio _dio = Dio();

  /// Downloads a file only if there is a connection.
  /// Returns the path to the downloaded file.
  Future<String?> downloadMedia(String url, String savePath) async {
    // 1. Check Connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception("No Internet Connection");
    }

    // 2. Perform Download
    try {
      await _dio.download(url, savePath);
      return savePath;
    } catch (e) {
      // Handle Dio errors (timeout, 404, etc.)
      print("Download failed: $e");
      return null;
    }
  }
}
