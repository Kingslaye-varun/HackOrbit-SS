import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/core/services/gemini_api.dart';
import 'package:sportif_ai/features/ai_dietician/data/diet_repository.dart';
import 'package:sportif_ai/features/ai_dietician/domain/diet_plan_usecase.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = false;
  MealPlan? result;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Generate meal plan automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generatePlan();
    });
  }

  Future<void> generatePlan() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      if (mounted) {
        setState(() {
          _error = "User not logged in";
        });
      }
      return;
    }

    if (user.gender == null || user.age == null || user.weight == null || 
        user.height == null || user.fitnessGoal == null || 
        user.sport == null || user.activityLevel == null) {
      if (mounted) {
        setState(() {
          _error = "Please complete your profile with all required information";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final input = DietInput(
        gender: user.gender!,
        age: user.age!,
        weight: user.weight!,
        height: user.height!,
        goal: user.fitnessGoal!,
        sport: user.sport!,
        activityLevel: user.activityLevel!,
      );

      final useCase = DietPlanUseCase();
      
      // If generate is async, await it. If sync, this will still work
      final plan = await Future.value(useCase.generate(input));

      if (mounted) {
        setState(() {
          result = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error generating meal plan: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchSuggestions(MealPlan plan) async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      _showErrorSnackBar("User not logged in");
      return;
    }
    
    final api = GeminiAPI();

    try {
      final meals = await api.getMealSuggestions(
        user: user,
        mealPlan: plan,
      );

      if (!mounted) return;

      // Validate meals data
      if (meals.isEmpty) {
        _showErrorSnackBar("No meal suggestions found");
        return;
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Meal Suggestions"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                
                // Safe access to meal data
                final title = meal['title']?.toString() ?? 'Unknown meal';
                final description = meal['description']?.toString() ?? '';
                final calories = meal['calories']?.toString() ?? '0';
                final protein = meal['protein']?.toString() ?? '0';
                final carbs = meal['carbs']?.toString() ?? '0';
                final fat = meal['fat']?.toString() ?? '0';
                final cost = meal['cost']?.toString() ?? 'Medium';
                final prepTime = meal['preparation_time']?.toString() ?? '30 minutes';
                final region = meal['region']?.toString() ?? 'India/Asia';
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "🍽 $calories kcal | 💰 $cost | 🕒 $prepTime",
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (description.isNotEmpty) ...[                              
                              Text(description),
                              const SizedBox(height: 8),
                            ],
                            Text("Region: $region"),
                            const SizedBox(height: 8),
                            Text(
                              "Nutrition: 💪 ${protein}g protein | 🍞 ${carbs}g carbs | 🥑 ${fat}g fat",
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _logMeal(meal, dialogContext),
                              child: const Text("Add to My Meals"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Error fetching suggestions: ${e.toString()}");
      }
    }
  }

  void _logMeal(Map<String, dynamic> meal, BuildContext dialogContext) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      _showErrorSnackBar("User not logged in");
      return;
    }

    try {
      // Extract additional meal information for logging
      final description = meal['description']?.toString() ?? '';
      final cost = meal['cost']?.toString() ?? 'Medium';
      final prepTime = meal['preparation_time']?.toString() ?? '30 minutes';
      final region = meal['region']?.toString() ?? 'India/Asia';
      
      DietRepository().logMealToMongo(
        userId: user.uid,
        mealTitle: meal['title']?.toString() ?? 'Unknown meal',
        calories: meal['calories'] ?? 0,
        protein: meal['protein']?.toString() ?? '0',
        carbs: meal['carbs']?.toString() ?? '0',
        fat: meal['fat']?.toString() ?? '0',
        mealType: _determineMealType(), // Dynamic meal type
        // Add additional fields if DietRepository supports them
        // description: description,
        // cost: cost,
        // preparationTime: prepTime,
        // region: region,
      );
      
      Navigator.pop(dialogContext); // Close dialog
      _showSuccessSnackBar("Meal logged successfully!");
    } catch (e) {
      _showErrorSnackBar("Error logging meal: ${e.toString()}");
    }
  }

  String _determineMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Breakfast";
    if (hour < 16) return "Lunch";
    if (hour < 20) return "Dinner";
    return "Snack";
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Meal Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => generatePlan(),
            tooltip: "Regenerate meal plan",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile summary
            if (user != null) ...[              
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.name ?? 'User'}'s Nutrition Plan",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Sport: ${user.sport ?? 'Not specified'}"),
                      Text("Goal: ${user.fitnessGoal ?? 'Not specified'}"),
                      if (user.weight != null && user.height != null)
                        Text("Stats: ${user.weight} kg, ${user.height} cm"),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            if (_isLoading) ...[              
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Generating your personalized meal plan..."),
                  ],
                ),
              ),
            ] else if (_error != null) ...[              
              Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Error",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: generatePlan,
                            child: const Text("Retry"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Go Back"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (result != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Meal Plan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "🔥 Calories: ${result!.calories ?? 0}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("💪 Protein: ${result!.protein ?? 0}g"),
                      Text("🍞 Carbs: ${result!.carbs ?? 0}g"),
                      Text("🥑 Fats: ${result!.fats ?? 0}g"),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => fetchSuggestions(result!),
                          child: const Text("Get Meal Suggestions"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}