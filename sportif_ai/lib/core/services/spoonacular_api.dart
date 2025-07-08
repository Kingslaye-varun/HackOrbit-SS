import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sportif_ai/config/api_config.dart';

class SpoonacularAPI {
  // Using ApiConfig for API key management
  final String apiKey = ApiConfig.spoonacularApiKey;

  Future<List<Map<String, dynamic>>> getMealSuggestions({
    required double maxCalories,
    required double maxProtein,
    required double maxCarbs,
    required double maxFats,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.spoonacularBaseUrl}/recipes/findByNutrients"
      "?maxCalories=${maxCalories.round()}"
      "&maxProtein=${maxProtein.round()}"
      "&maxCarbs=${maxCarbs.round()}"
      "&maxFat=${maxFats.round()}"
      "&number=5"
      "&apiKey=$apiKey",
    );

    final response = await http.get(url).timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch meal suggestions: ${response.body}");
    }
  }
}
