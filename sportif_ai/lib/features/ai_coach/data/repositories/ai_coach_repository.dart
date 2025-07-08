import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/features/ai_coach/domain/models/drill_result.dart';

class AiCoachRepository {
  // No need for ApiConfig instance since we use static methods
  AiCoachRepository();

  Future<bool> saveDrillResult(DrillResult drillResult) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/drill-results'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(drillResult.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 201) {
        throw Exception("Failed to save drill result: ${response.body}");
      }

      return true;
    } catch (e) {
      throw Exception("Error saving drill result: $e");
    }
  }

  Future<List<DrillResult>> getUserDrillResults(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/drill-results/$userId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception("Failed to get drill results: ${response.body}");
      }

      final List<dynamic> resultsJson = jsonDecode(response.body);
      return resultsJson.map((json) => DrillResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Error getting drill results: $e");
    }
  }

  // Method to call Python script via HTTP
  Future<Map<String, dynamic>> runDrillAnalysis(String drillName, String videoPath) async {
    try {
      // This would be the endpoint where your Python script is hosted
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/analyze-drill'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "drill": drillName,
          "video_path": videoPath,
        }),
      ).timeout(const Duration(minutes: 2)); // Longer timeout for video processing

      if (response.statusCode != 200) {
        throw Exception("Failed to analyze drill: ${response.body}");
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Error analyzing drill: $e");
    }
  }
}