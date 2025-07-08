import 'package:flutter/material.dart';
import 'package:sportif_ai/features/auth/presentation/login_screen.dart';
import 'package:sportif_ai/features/auth/presentation/signup_screen.dart';
import 'package:sportif_ai/features/auth/presentation/sport_selection_screen.dart';
import 'package:sportif_ai/features/debug/network_debug_screen.dart';
import 'package:sportif_ai/features/home/homescreen.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/hydration_tracker.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/dietician_dashboard.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/meal_plan_screen.dart';
import 'package:sportif_ai/features/profile_builder/presentation/profile_screen.dart';
import 'package:sportif_ai/features/chatbot/chatbot.dart';
import 'package:sportif_ai/features/tournament_tracker/presentation/tournament-tracker.dart';
import 'package:sportif_ai/features/Scout_players/scout_players.dart';
import 'package:sportif_ai/features/Scout_players/player_details_screen.dart';
import 'package:sportif_ai/features/Scout_players/player_model.dart';
import 'package:sportif_ai/features/ai_coach/presentation/ai_coach_screen.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String sportSelection = '/sport-selection';
  static const String networkDebug = '/network-debug';
  static const String profile = '/profile';
  static const String hydrationTracker = '/hydration-tracker';
  static const String dieticianDashboard = '/dietician-dashboard';
  static const String mealPlan = '/meal-plan';
  static const String chatbot = '/chatbot';
  static const String tournamentTracker = '/tournament-tracker';
  static const String scoutPlayers = '/scout-players';
  static const String aiCoach = '/ai-coach';

  // Route map
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      home: (context) => const HomeScreen(),
      sportSelection: (context) => const SportSelectionScreen(),
      networkDebug: (context) => const NetworkDebugScreen(),
      profile: (context) => const ProfileScreen(),
      hydrationTracker: (context) => const HydrationTracker(),
      dieticianDashboard: (context) => const DieticianDashboard(),
      mealPlan: (context) => const MealPlanScreen(),
      chatbot: (context) => const GeminiNutritionChatbot(),
      tournamentTracker: (context) => const TournamentTrackerScreen(),
      scoutPlayers: (context) => const ScoutPlayersScreen(),
      aiCoach: (context) => const AiCoachScreen(),
    };
  }

  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToSportSelection(BuildContext context) {
    Navigator.pushNamed(context, sportSelection);
  }

  static void navigateToNetworkDebug(BuildContext context) {
    Navigator.pushNamed(context, networkDebug);
  }
  
  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }
  
  static void navigateToHydrationTracker(BuildContext context) {
    Navigator.pushNamed(context, hydrationTracker);
  }
  
  static void navigateToDieticianDashboard(BuildContext context) {
    Navigator.pushNamed(context, dieticianDashboard);
  }
  
  static void navigateToMealPlan(BuildContext context) {
    Navigator.pushNamed(context, mealPlan);
  }
  
  static void navigateToChatbot(BuildContext context) {
    Navigator.pushNamed(context, chatbot);
  }
  
  static void navigateToTournamentTracker(BuildContext context) {
    Navigator.pushNamed(context, tournamentTracker);
  }
  
  static void navigateToScoutPlayers(BuildContext context) {
    Navigator.pushNamed(context, scoutPlayers);
  }
  
  static void navigateToAiCoach(BuildContext context) {
    Navigator.pushNamed(context, aiCoach);
  }
  
  static void navigateToPlayerDetails(BuildContext context, Player player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerDetailsScreen(player: player),
      ),
    );
  }
}