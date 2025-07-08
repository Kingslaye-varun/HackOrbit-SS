import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';

/// A utility class to help with network operations and diagnostics
class NetworkHelper {
  /// Test if a server is reachable at the given URL
  /// 
  /// Returns a [Future<bool>] indicating if the server is reachable
  /// Optionally specify a [timeout] in milliseconds (default: uses ApiConfig.connectionTimeout)
  static Future<bool> isServerReachable(String url, {Duration? timeout}) async {
    try {
      final response = await http.get(Uri.parse(url))
          .timeout(timeout ?? ApiConfig.connectionTimeout);
      return response.statusCode < 500; // Consider any non-server error as reachable
    } catch (e) {
      return false;
    }
  }

  /// Test multiple server URLs and return the first one that is reachable
  /// 
  /// Returns a [Future<String?>] with the first reachable URL, or null if none are reachable
  /// Optionally specify a [timeout] (default: uses ApiConfig.connectionTimeout)
  static Future<String?> findReachableServer(
      List<String> serverUrls, {Duration? timeout}) async {
    for (final url in serverUrls) {
      if (await isServerReachable(url, timeout: timeout)) {
        return url;
      }
    }
    return null;
  }

  /// Get the appropriate base URL for the current platform
  /// 
  /// This method is deprecated and will be removed in a future version.
  /// Use ApiConfig.baseUrl instead.
  @Deprecated('Use ApiConfig.baseUrl instead')
  static String getPlatformAppropriateBaseUrl(String port, {String ip = '172.26.0.1'}) {
    // Always use the provided IP address
    return 'http://$ip:$port';
  }

  /// Log HTTP request details for debugging
  static void logRequest(String method, String url, Map<String, String>? headers, dynamic body) {
    print('🌐 HTTP Request: $method $url');
    if (headers != null) {
      print('📋 Headers: ${headers.toString()}');
    }
    if (body != null) {
      print('📦 Body: $body');
    }
  }

  /// Log HTTP response details for debugging
  static void logResponse(http.Response response, {bool includeBody = true}) {
    print('🔄 HTTP Response: ${response.statusCode} from ${response.request?.url}');
    if (includeBody) {
      // Limit body length to avoid huge logs
      final bodyPreview = response.body.length > 1000 
          ? '${response.body.substring(0, 1000)}... (truncated)' 
          : response.body;
      print('📄 Body: $bodyPreview');
    }
  }

  /// Create a client with a specified timeout
  static http.Client createTimeoutClient({Duration? timeout}) {
    // Note: The actual timeout is applied when making requests, not when creating the client
    return http.Client();
  }
}