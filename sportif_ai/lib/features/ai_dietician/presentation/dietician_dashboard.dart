import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/features/ai_dietician/domain/diet_plan_usecase.dart';
import 'package:sportif_ai/features/ai_dietician/presentation/meal_plan_screen.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'package:sportif_ai/routes/app_routes.dart';

class DieticianDashboard extends StatefulWidget {
  const DieticianDashboard({super.key});

  @override
  State<DieticianDashboard> createState() => _DieticianDashboardState();
}

class _DieticianDashboardState extends State<DieticianDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  MealPlan? _currentMealPlan;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserMealPlan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserMealPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null && user.gender != null && user.age != null && 
          user.height != null && user.weight != null && 
          user.fitnessGoal != null && user.sport != null && 
          user.activityLevel != null) {
        
        // Create diet input from user profile
        final dietInput = DietInput(
          gender: user.gender!,
          age: user.age!,
          weight: user.weight!,
          height: user.height!,
          goal: user.fitnessGoal!,
          sport: user.sport!,
          activityLevel: user.activityLevel!,
        );

        // Generate meal plan
        final mealPlan = DietPlanUseCase().generate(dietInput);
        setState(() {
          _currentMealPlan = mealPlan;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meal plan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dietician'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Meal Plan'),
            Tab(text: 'Progress'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserMealPlan,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(user),
          _buildMealPlanTab(user),
          _buildProgressTab(user),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateToMealPlan(context);
        },
        child: const Icon(Icons.restaurant_menu),
        tooltip: 'Create Meal Plan',
      ),
    );
  }

  Widget _buildDashboardTab(UserModel user) {
    bool hasCompleteProfile = user.gender != null && 
                             user.age != null && 
                             user.height != null && 
                             user.weight != null && 
                             user.dietaryPreference != null && 
                             user.fitnessGoal != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!) as ImageProvider
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.sport ?? 'No sport selected',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  if (!hasCompleteProfile)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Complete Your Profile',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Please complete your profile to get personalized diet recommendations.',
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    AppRoutes.navigateToProfile(context);
                                  },
                                  child: const Text('Update Profile'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hasCompleteProfile) ...[                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Age', '${user.age}', Icons.calendar_today),
                        _buildStatCard('Height', '${user.height} cm', Icons.height),
                        _buildStatCard('Weight', '${user.weight} kg', Icons.monitor_weight_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Gender', user.gender ?? 'N/A', Icons.person_outline),
                        _buildStatCard('Diet', user.dietaryPreference ?? 'N/A', Icons.restaurant_menu),
                        _buildStatCard('Goal', user.fitnessGoal ?? 'N/A', Icons.fitness_center),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Nutrition',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentMealPlan != null) ...[            
            _buildNutritionCard('Calories', '${_currentMealPlan!.calories.toInt()} kcal', Colors.orange),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard('Protein', '${_currentMealPlan!.protein.toInt()} g', Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard('Carbs', '${_currentMealPlan!.carbs.toInt()} g', Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard('Fats', '${_currentMealPlan!.fats.toInt()} g', Colors.blue),
                ),
              ],
            ),
          ] else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.no_food, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text(
                      'No meal plan available',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        AppRoutes.navigateToMealPlan(context);
                      },
                      child: const Text('Create Meal Plan'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reminders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Hydration Reminders'),
                    subtitle: const Text('Drink water throughout the day'),
                    value: user.hydrationReminder,
                    onChanged: (bool value) {
                      // This would be handled in a real app by updating the user profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Update your preferences in the profile screen')),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Meal Reminders'),
                    subtitle: const Text('Don\'t miss your scheduled meals'),
                    value: user.mealReminder,
                    onChanged: (bool value) {
                      // This would be handled in a real app by updating the user profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Update your preferences in the profile screen')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanTab(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Meal Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // This would be populated with actual meal plan data in a real app
          for (var i = 0; i < 7; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(i),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildMealRow('Breakfast', 'Oatmeal with fruits', '300 kcal'),
                    const Divider(),
                    _buildMealRow('Lunch', 'Grilled chicken salad', '450 kcal'),
                    const Divider(),
                    _buildMealRow('Dinner', 'Salmon with vegetables', '500 kcal'),
                    const Divider(),
                    _buildMealRow('Snack', 'Greek yogurt with nuts', '200 kcal'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Progress Tracking',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your fitness journey over time',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress tracking coming soon!')),
              );
            },
            child: const Text('Start Tracking'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(String mealType, String mealName, String calories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(
              mealType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(mealName),
          ),
          Text(
            calories,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayIndex];
  }
}