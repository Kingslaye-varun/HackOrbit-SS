import 'package:flutter/material.dart';
// Change these imports:
import 'package:sportif_ai/core/services/spoonacular_api.dart';
import 'package:sportif_ai/features/ai_dietician/data/diet_repository.dart';
import 'package:sportif_ai/features/ai_dietician/domain/diet_plan_usecase.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers & Variables
  String gender = "Male";
  String goal = "Gain Muscle";
  String sport = "Tennis";
  double activityLevel = 1.55;

  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  MealPlan? result;

  void generatePlan() {
    if (_formKey.currentState!.validate()) {
      final input = DietInput(
        gender: gender,
        age: int.parse(ageController.text),
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
        goal: goal,
        sport: sport,
        activityLevel: activityLevel,
      );

      final useCase = DietPlanUseCase();
      final plan = useCase.generate(input);

      setState(() => result = plan);
    }
  }

  void fetchSuggestions(MealPlan plan) async {
    final api = SpoonacularAPI();

    try {
      final meals = await api.getMealSuggestions(
        maxCalories: plan.calories.toDouble(),
        maxProtein: plan.protein,
        maxCarbs: plan.carbs,
        maxFats: plan.fats,
      );

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Meal Suggestions"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return ListTile(
                      title: Text(meal['title']),
                      subtitle: Text(
                        "🍽 ${meal['calories']} kcal, "
                        "💪 ${meal['protein']}, "
                        "🍞 ${meal['carbs']}, "
                        "🥑 ${meal['fat']}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // Log meal to MongoDB
                          DietRepository().logMealToMongo(
                            userId: "user123", // Replace with actual user ID
                            mealTitle: meal['title'],
                            calories: meal['calories'],
                            protein: meal['protein'].toString(),
                            carbs: meal['carbs'].toString(),
                            fat: meal['fat'].toString(),
                            mealType: "Lunch", // Example meal type
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Meal logged!")),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Dietician")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: gender,
                items:
                    ["Male", "Female"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => gender = val!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (v) => v!.isEmpty ? "Enter age" : null,
              ),
              TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                validator: (v) => v!.isEmpty ? "Enter weight" : null,
              ),
              TextFormField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                validator: (v) => v!.isEmpty ? "Enter height" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: goal,
                items:
                    ["Gain Muscle", "Cut Fat", "Maintain"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => goal = val!),
                decoration: const InputDecoration(labelText: "Goal"),
              ),
              DropdownButtonFormField<String>(
                value: sport,
                items:
                    ["Tennis", "Basketball", "Weightlifting", "Running"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => sport = val!),
                decoration: const InputDecoration(labelText: "Sport"),
              ),
              const SizedBox(height: 10),
              Slider(
                value: activityLevel,
                min: 1.2,
                max: 2.0,
                divisions: 8,
                label: activityLevel.toStringAsFixed(2),
                onChanged: (val) => setState(() => activityLevel = val),
              ),
              const Text(
                "Activity Level (1.2 = sedentary, 2.0 = intense training)",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: generatePlan,
                child: const Text("Generate Meal Plan"),
              ),
              const SizedBox(height: 20),
              if (result != null) ...[
                Text(
                  "🔥 Calories: ${result!.calories}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("💪 Protein: ${result!.protein}g"),
                Text("🍞 Carbs: ${result!.carbs}g"),
                Text("🥑 Fats: ${result!.fats}g"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => fetchSuggestions(result!),
                  child: const Text("Suggest Meals"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
