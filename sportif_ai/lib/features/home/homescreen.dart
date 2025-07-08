import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sportif_ai/features/Scout_players/scout_players.dart';
// // Remove these imports:
// import 'package:sportif_ai/features/tournament-tracker/tournament-tracker.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/meal_plan_screen.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/dietician_dashboard.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/hydration_tracker.dart';
import 'package:sportif_ai/features/chatbot/chatbot.dart';

import 'package:provider/provider.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'package:sportif_ai/features/debug/network_debug_screen.dart';
import 'package:sportif_ai/features/profile_builder/presentation/profile_screen.dart';
import 'package:sportif_ai/features/tournament_tracker/presentation/tournament-tracker.dart';
import 'package:sportif_ai/routes/app_routes.dart';
import 'package:sportif_ai/features/achievements/presentation/achievements_screen.dart';
// import 'package:sportif_ai/features/tournament_tracker/presentation/tournament_tracker_screen.dart';
// Remove the duplicate main() function and SportifAIApp class
void main() {
  runApp(const SportifAIApp());
}

class SportifAIApp extends StatelessWidget {
  const SportifAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sportif-AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Sportif-AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF2E3192),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 30),
            onPressed: () {
              AppRoutes.navigateToProfile(context);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildMainFeaturesGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E3192)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Sportif-AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your AI Sports Companion',
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              AppRoutes.navigateToProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms & Conditions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Network Debug'),
            onTap: () {
              AppRoutes.navigateToNetworkDebug(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.signOut();
              AppRoutes.navigateToLogin(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'STRANGER STRINGS',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF2E3192),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back,',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Athlete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatItem('Today\'s Drill', 'Leg Day'),
                const SizedBox(width: 15),
                _buildStatItem('Next Event', 'July 15'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFeaturesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureButton(
          icon: FontAwesomeIcons.robot,
          color: const Color(0xFF6A5ACD),
          label: 'AI Coach',
          onTap: () {
            AppRoutes.navigateToAiCoach(context);
          },
        ),
        _buildFeatureButton(
          icon: FontAwesomeIcons.dumbbell,
          color: const Color(0xFF20B2AA),
          label: 'Today\'s Drill',
        ),
        _buildFeatureButton(
          icon: FontAwesomeIcons.comment,
          color: const Color(0xFFFF8C00),
          label: 'Chatbot',
          onTap: () {
            AppRoutes.navigateToChatbot(context);
          },
        ),
        _buildFeatureButton(
          icon: FontAwesomeIcons.tint,
          color: const Color(0xFF1E90FF),
          label: 'Hydration Tracker',
          onTap: () {
            AppRoutes.navigateToHydrationTracker(context);
          },
        ),
        _buildFeatureButton(
          icon: FontAwesomeIcons.search,
          color: const Color(0xFF4169E1),
          label: 'Search Scout',
          onTap: () {
            AppRoutes.navigateToScoutPlayers(context);
          },
        ),
        _buildFeatureButton(
          icon: FontAwesomeIcons.medal,
          color: const Color(0xFFFFD700),
          label: 'Achievements',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AchievementsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2E3192),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.appleAlt),
          label: 'AI Nutritionist',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.calendarAlt),
          label: 'Tournament Tracker',
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        if (index == 0) {
          // Home tab - already on home screen
        } else if (index == 1) {
          // AI Nutritionist tab
          AppRoutes.navigateToDieticianDashboard(context);
        } else if (index == 2) {
          // Tournament Tracker tab
          AppRoutes.navigateToTournamentTracker(context);
        }
      },
    );
  }
}