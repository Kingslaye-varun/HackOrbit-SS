import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URLs for different environments
  // For local development on physical device, use your laptop's IP address
  static const String localIpUrl = 'http://192.168.0.100:5000/api';
  
  // For emulator, use special emulator address
  static const String emulatorUrl = 'http://10.0.2.2:5000/api'; // Keep this for Android emulator
  
  // For production
  static const String productionUrl = 'https://your-production-server.com/api';
  
  // Current active base URL - always set to localIpUrl
  static String _currentBaseUrl = localIpUrl;

  // Getter for the current base URL
  static String get baseUrl => _currentBaseUrl;

  // Method to set the base URL
  static void setBaseUrl(String url) {
    _currentBaseUrl = url;
  }
  
  // Method to update the local IP URL
  static void updateLocalIpUrl(String newUrl) {
    // This is just for testing - in a real app, you'd want to persist this
    setBaseUrl(newUrl);
    print('Updated local IP URL to: $newUrl');
  }

  // Method to set the appropriate base URL based on platform and environment
  static void setupForPlatform() {
    if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      // For Android emulator, use 10.0.2.2 which maps to host's localhost
      bool isEmulator = false;
      try {
        // This is a simple heuristic to detect emulators
        // Most emulators have model names containing 'emulator' or 'sdk'
        isEmulator = Platform.environment.containsKey('ANDROID_EMULATOR') || 
                     Platform.environment.containsKey('ANDROID_SDK');
      } catch (e) {
        print('Error detecting emulator: $e');
      }
      
      if (isEmulator) {
        _currentBaseUrl = emulatorUrl;
        print('Running on Android emulator, using URL: $_currentBaseUrl');
      } else {
        _currentBaseUrl = localIpUrl;
        print('Running on Android device, using URL: $_currentBaseUrl');
      }
    } else if (Platform.isIOS) {
      // For iOS simulator, also use special address
      bool isSimulator = false;
      try {
        // This is a simple heuristic to detect simulators
        isSimulator = Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
      } catch (e) {
        print('Error detecting simulator: $e');
      }
      
      if (isSimulator) {
        _currentBaseUrl = 'http://localhost:5000/api';
        print('Running on iOS simulator, using URL: $_currentBaseUrl');
      } else {
        _currentBaseUrl = localIpUrl;
        print('Running on iOS device, using URL: $_currentBaseUrl');
      }
    } else {
      // For web or desktop, use localhost
      _currentBaseUrl = 'http://localhost:5000/api';
      print('Running on ${Platform.operatingSystem}, using URL: $_currentBaseUrl');
    }
  }

  // API Endpoints
  static String get usersEndpoint => '$_currentBaseUrl/users';
  static String userEndpoint(String uid) => '$_currentBaseUrl/users/$uid';
  static String get dietPlansEndpoint => '$_currentBaseUrl/diet-plan';
  static String dietPlanEndpoint(String id) => '$_currentBaseUrl/diet-plan/$id';
  static String get mealLogsEndpoint => '$_currentBaseUrl/meal-log';
  static String userMealLogsEndpoint(String userId) => '$_currentBaseUrl/meal-log/$userId';
  static String get tournamentsEndpoint => '$_currentBaseUrl/tournaments';
  static String userTournamentsEndpoint(String userId) => '$_currentBaseUrl/tournaments/user/$userId';
  static String tournamentEndpoint(String id) => '$_currentBaseUrl/tournaments/$id';
  
  // External API keys
  static const String spoonacularApiKey = "74fc91e015f447158111e37732cfc4b7";
  static String get spoonacularBaseUrl => 'https://api.spoonacular.com';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration initialBackoff = Duration(milliseconds: 500);
  
  // Debug helper method to test connectivity
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $_currentBaseUrl');
      final response = await http.get(
        Uri.parse('$_currentBaseUrl/health'),
      ).timeout(connectionTimeout);
      
      print('Connection test result: ${response.statusCode} - ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}