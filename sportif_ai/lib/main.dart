import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'package:sportif_ai/features/auth/presentation/login_screen.dart';
import 'package:sportif_ai/features/home/homescreen.dart';
import 'package:sportif_ai/firebase_options.dart';
import 'package:sportif_ai/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions
              .currentPlatform, // Uncomment if you have firebase_options.dart
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Sportif AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E3192),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E3192),
            primary: const Color(0xFF2E3192),
          ),
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        // Register all routes
        routes: AppRoutes.getRoutes(),
        // Determine initial route based on authentication state
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
