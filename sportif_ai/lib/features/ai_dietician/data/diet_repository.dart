import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/diet_plan_usecase.dart';
import 'package:sportif_ai/config/api_config.dart';

class DietRepository {
  // Using ApiConfig for endpoint management
  String get baseUrl => ApiConfig.dietPlansEndpoint;

  Future<void> saveMealPlan(
    MealPlan plan,
    DietInput input,
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        // "userId": userId,
        "gender": input.gender,
        "age": input.age,
        "weight": input.weight,
        "height": input.height,
        "goal": input.goal,
        "sport": input.sport,
        "activityLevel": input.activityLevel,
        "calories": plan.calories,
        "protein": plan.protein,
        "carbs": plan.carbs,
        "fats": plan.fats,
      }),
    ).timeout(ApiConfig.connectionTimeout);
    
    if (response.statusCode != 201) {
      throw Exception("Failed to save plan: ${response.body}");
    }
  }

  Future<void> logMealToMongo({
    required String userId,
    required String mealTitle,
    required int calories,
    required String protein,
    required String carbs,
    required String fat,
    required String mealType,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.mealLogsEndpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "mealTitle": mealTitle,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat,
        "mealType": mealType,
      }),
    ).timeout(ApiConfig.connectionTimeout);
    
    if (response.statusCode != 201) {
      throw Exception("Failed to log meal: ${response.body}");
    }
  }
}