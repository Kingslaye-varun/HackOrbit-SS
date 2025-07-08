import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';

class NetworkUtils {
  // Private constructor to prevent instantiation
  NetworkUtils._();

  /// Checks if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Tests connectivity to the backend server
  static Future<bool> canReachBackend() async {
    return ApiConfig.testConnection();
  }
  
  /// Tests a specific endpoint and returns the response
  static Future<http.Response> testEndpoint(String url) async {
    print('Testing endpoint: $url');
    return await http.get(
      Uri.parse(url),
    ).timeout(ApiConfig.connectionTimeout);
  }

  /// Gets the device's IP address
  static Future<String?> getDeviceIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      if (interfaces.isNotEmpty) {
        for (var interface in interfaces) {
          if (interface.name.contains('wlan') || 
              interface.name.contains('en0') || 
              interface.name.contains('wifi')) {
            if (interface.addresses.isNotEmpty) {
              return interface.addresses.first.address;
            }
          }
        }
        // If no wifi interface found, return the first available
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      print('Error getting device IP: $e');
    }
    return null;
  }

  /// Gets the laptop/server IP address from the current API configuration
  static String getServerIpAddress() {
    final url = ApiConfig.baseUrl;
    final uri = Uri.parse(url);
    return uri.host;
  }

  /// Runs a comprehensive network diagnostic
  static Future<Map<String, dynamic>> runNetworkDiagnostic() async {
    final results = <String, dynamic>{};
    
    // Check internet connectivity
    results['hasInternet'] = await hasInternetConnection();
    
    // Get device IP
    results['deviceIp'] = await getDeviceIpAddress();
    
    // Get server IP from config
    results['serverIp'] = getServerIpAddress();
    
    // Check if backend is reachable
    results['backendReachable'] = await canReachBackend();
    
    // Get current API URL
    results['apiUrl'] = ApiConfig.baseUrl;
    
    // Try to ping the server
    try {
      final pingResult = await Process.run('ping', ['-c', '3', getServerIpAddress()]);
      results['pingOutput'] = pingResult.stdout.toString();
      results['pingSuccess'] = !pingResult.stderr.toString().contains('error');
    } catch (e) {
      results['pingOutput'] = 'Error running ping: $e';
      results['pingSuccess'] = false;
    }
    
    return results;
  }

  /// Prints a formatted network diagnostic report
  static Future<void> printNetworkDiagnosticReport() async {
    final results = await runNetworkDiagnostic();
    
    print('\n======= NETWORK DIAGNOSTIC REPORT =======');
    print('Internet Connection: ${results['hasInternet'] ? '✅ CONNECTED' : '❌ DISCONNECTED'}');
    print('Device IP Address: ${results['deviceIp'] ?? 'Unknown'}');
    print('Server IP Address: ${results['serverIp']}');
    print('API URL: ${results['apiUrl']}');
    print('Backend Reachable: ${results['backendReachable'] ? '✅ YES' : '❌ NO'}');
    print('Ping Success: ${results['pingSuccess'] ? '✅ YES' : '❌ NO'}');
    print('\nPing Output:\n${results['pingOutput']}');
    print('=========================================\n');
  }
}