import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sportif_ai/features/ai_dietician/domain/diet_plan_usecase.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/core/services/meal_prompt_template.dart';

class GeminiAPI {
  // Using ApiConfig for API key management
  final String apiKey = ApiConfig.geminiApiKey;
  final String baseUrl = ApiConfig.geminiBaseUrl;

  Future<List<Map<String, dynamic>>> getMealSuggestions({
    required UserModel user,
    required MealPlan mealPlan,
  }) async {
    // Validate user data
    if (user.gender == null || user.age == null || user.height == null ||
        user.weight == null || user.dietaryPreference == null ||
        user.fitnessGoal == null || user.sport == null) {
      throw Exception("Incomplete user profile data");
    }

    // Get prompt from template
    final String prompt = MealPromptTemplate.getPromptForMealSuggestions(
      gender: user.gender ?? '',
      age: user.age ?? 0,
      height: user.height ?? 0,
      weight: user.weight ?? 0,
      dietaryPreference: user.dietaryPreference ?? 'Non-Vegetarian',
      fitnessGoal: user.fitnessGoal ?? '',
      sport: user.sport ?? '',
      calories: mealPlan.calories ?? 0,
      protein: (mealPlan.protein ?? 0).toInt(),
      carbs: (mealPlan.carbs ?? 0).toInt(),
      fats: (mealPlan.fats ?? 0).toInt(),
    );

    // Prepare request body
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 1024,
      }
    };

    // Make API request
    final response = await http.post(
      Uri.parse("$baseUrl?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Extract the text response from Gemini
      final String generatedText = data['candidates'][0]['content']['parts'][0]['text'];
      
      // Parse the JSON array from the text response
      // We need to handle potential formatting issues in the response
      try {
        // Find JSON array in the response
        final RegExp jsonRegex = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true);
        final match = jsonRegex.firstMatch(generatedText);
        
        if (match != null) {
          final String jsonStr = match.group(0) ?? '[]';
          final List<dynamic> meals = json.decode(jsonStr);
          
          // Convert to the expected format and clean up values
          return meals.map((meal) {
            // Convert string values to numeric where needed
            int calories = meal['calories'] is int 
                ? meal['calories'] 
                : int.tryParse(meal['calories'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            // Parse protein, carbs, and fat values to ensure they're numeric
            var protein = meal['protein'] is int 
                ? meal['protein'] 
                : int.tryParse(meal['protein'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            var carbs = meal['carbs'] is int 
                ? meal['carbs'] 
                : int.tryParse(meal['carbs'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            var fat = meal['fat'] is int 
                ? meal['fat'] 
                : int.tryParse(meal['fat'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            return {
              'title': meal['title'] ?? 'Unknown Meal',
              'description': meal['description'] ?? '',
              'calories': calories,
              'protein': protein,
              'carbs': carbs,
              'fat': fat,
              'cost': meal['cost'] ?? 'Medium',
              'preparation_time': meal['preparation_time'] ?? '30 minutes',
              'region': meal['region'] ?? 'India/Asia',
            };
          }).toList();
        }
        
        // If no JSON array found, try to parse the entire response as JSON
        try {
          final List<dynamic> meals = json.decode(generatedText);
          return meals.map((meal) {
            int calories = meal['calories'] is int 
                ? meal['calories'] 
                : int.tryParse(meal['calories'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            // Parse protein, carbs, and fat values to ensure they're numeric
            var protein = meal['protein'] is int 
                ? meal['protein'] 
                : int.tryParse(meal['protein'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            var carbs = meal['carbs'] is int 
                ? meal['carbs'] 
                : int.tryParse(meal['carbs'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            var fat = meal['fat'] is int 
                ? meal['fat'] 
                : int.tryParse(meal['fat'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                
            return {
              'title': meal['title'] ?? 'Unknown Meal',
              'description': meal['description'] ?? '',
              'calories': calories,
              'protein': protein,
              'carbs': carbs,
              'fat': fat,
              'cost': meal['cost'] ?? 'Medium',
              'preparation_time': meal['preparation_time'] ?? '30 minutes',
              'region': meal['region'] ?? 'India/Asia',
            };
          }).toList();
        } catch (e) {
          throw Exception("Failed to parse meal suggestions: $e");
        }
      } catch (e) {
        throw Exception("Failed to extract meal suggestions: $e");
      }
    } else {
      throw Exception("Failed to fetch meal suggestions: ${response.statusCode} - ${response.body}");
    }
  }
}