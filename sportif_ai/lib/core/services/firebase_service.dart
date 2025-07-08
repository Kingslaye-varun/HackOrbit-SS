import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/config/api_config.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  FirebaseService() {
    // Setup the appropriate base URL based on the platform
    ApiConfig.setupForPlatform();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? sport,
  }) async {
    UserCredential? userCredential;
    try {
      // Step 1: Create user in Firebase Authentication first
      print('Creating user in Firebase Authentication...');
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Successfully created user in Firebase with UID: ${userCredential.user?.uid}');

      // Step 2: Create user in MongoDB using the Firebase UID
      if (userCredential.user != null) {
        try {
          print('Now creating user in MongoDB with UID: ${userCredential.user!.uid}');
          await _createUserInMongoDB(
            uid: userCredential.user!.uid,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            sport: sport,
          );
          print('Successfully created user in MongoDB');
        } catch (mongoError) {
          // If MongoDB creation fails, we still return the Firebase user
          // but we throw a specific error that can be caught and handled
          print('Error creating user in MongoDB: $mongoError');
          throw Exception('MongoDB user creation failed: $mongoError');
        }
      }

      return userCredential;
    } catch (e) {
      // If Firebase Auth fails, or if we get here from the MongoDB error
      if (e.toString().contains('MongoDB')) {
        // If it's a MongoDB error, we already have a Firebase user
        // so we return the userCredential but also rethrow for error handling
        if (userCredential != null) {
          rethrow;
        }
      }
      // For Firebase Auth errors or if userCredential is null, just rethrow
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user in MongoDB with retry logic
  Future<void> _createUserInMongoDB({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    String? photoUrl,
    String? sport,
  }) async {
    print('Creating user in MongoDB with UID: $uid');
    
    final user = UserModel(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      sport: sport,
      createdAt: DateTime.now(),
    );

    // Use only the configured endpoint
    List<String> serverAddresses = [
      ApiConfig.usersEndpoint,                                // Primary (configured in ApiConfig)
    ];
    
    Exception? lastException;
    
    // Try each server address with retries
    for (String serverUrl in serverAddresses) {
      int retryCount = 0;
      final maxRetries = ApiConfig.maxRetries;
      
      while (retryCount < maxRetries) {
        try {
          print('Attempting to connect to: $serverUrl (Attempt ${retryCount + 1})');
          
          final response = await http.post(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user.toJson()),
          ).timeout(ApiConfig.connectionTimeout);
          
          print('Response status: ${response.statusCode}, body: ${response.body}');
          
          if (response.statusCode == 201) {
            print('Successfully created user in MongoDB with UID: $uid');
            return; // Success, exit the function
          } else {
            print('Failed with status code: ${response.statusCode}, body: ${response.body}');
            throw Exception('Failed to create user in MongoDB: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          print('Connection error (${retryCount + 1}/$maxRetries): $e');
          retryCount++;
          
          if (retryCount < maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(milliseconds: ApiConfig.initialBackoff.inMilliseconds * (1 << retryCount)));
          }
        }
      }
    }
    
    // If we get here, all attempts failed
    final errorMessage = 'Failed to create user in MongoDB after all attempts. Last error: ${lastException?.toString()}';
    print(errorMessage);
    throw Exception(errorMessage);
  }

  // Get user data with retry logic
  Future<UserModel?> getUserData(String uid) async {
    print('Getting user data for UID: $uid');
    
    // Use only the configured endpoint
    List<String> serverAddresses = [
      ApiConfig.userEndpoint(uid),                               // Primary (configured in ApiConfig)
    ];
    
    // Try each server address with retries
    for (String serverUrl in serverAddresses) {
      int retryCount = 0;
      final maxRetries = ApiConfig.maxRetries;
      
      while (retryCount < maxRetries) {
        try {
          print('Attempting to get user data from: $serverUrl (Attempt ${retryCount + 1})');
          
          final response = await http.get(
            Uri.parse(serverUrl),
          ).timeout(ApiConfig.connectionTimeout);
          
          print('Response status: ${response.statusCode}, body: ${response.body}');
          
          if (response.statusCode == 200) {
            print('Successfully retrieved user data for UID: $uid');
            return UserModel.fromJson(json.decode(response.body));
          } else if (response.statusCode == 404) {
            print('User not found with UID: $uid');
            return null; // User not found is a valid response
          } else {
            print('Failed with status code: ${response.statusCode}, body: ${response.body}');
          }
        } catch (e) {
          print('Connection error (${retryCount + 1}/$maxRetries): $e');
          retryCount++;
          
          if (retryCount < maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(milliseconds: ApiConfig.initialBackoff.inMilliseconds * (1 << retryCount)));
          }
        }
      }
    }
    
    // If we get here, all attempts failed
    print('Failed to get user data after all attempts for UID: $uid');
    return null;
  }

  // Update user data with retry logic
  Future<void> updateUserData(UserModel user) async {
    print('Updating user data for UID: ${user.uid}');
    
    // Use only the configured endpoint
    List<String> serverAddresses = [
      ApiConfig.userEndpoint(user.uid),                               // Primary (configured in ApiConfig)
    ];
    
    Exception? lastException;
    
    // Try each server address with retries
    for (String serverUrl in serverAddresses) {
      int retryCount = 0;
      final maxRetries = ApiConfig.maxRetries;
      
      while (retryCount < maxRetries) {
        try {
          print('Attempting to update user data at: $serverUrl (Attempt ${retryCount + 1})');
          
          final response = await http.put(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user.toJson()),
          ).timeout(ApiConfig.connectionTimeout);
          
          print('Response status: ${response.statusCode}, body: ${response.body}');
          
          if (response.statusCode == 200) {
            print('Successfully updated user in MongoDB with UID: ${user.uid}');
            return; // Success, exit the function
          } else {
            print('Failed with status code: ${response.statusCode}, body: ${response.body}');
            throw Exception('Failed to update user in MongoDB: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          print('Connection error (${retryCount + 1}/$maxRetries): $e');
          retryCount++;
          
          if (retryCount < maxRetries) {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(milliseconds: ApiConfig.initialBackoff.inMilliseconds * (1 << retryCount)));
          }
        }
      }
    }
    
    // If we get here, all attempts failed
    final errorMessage = 'Failed to update user in MongoDB after all attempts for UID: ${user.uid}. Last error: ${lastException?.toString()}';
    print(errorMessage);
    throw Exception(errorMessage);
  }
}
