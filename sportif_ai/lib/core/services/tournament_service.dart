import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/core/models/tournament_model.dart';

class TournamentService {
  // Private constructor to prevent instantiation
  TournamentService._();

  // API endpoint
  static String get _tournamentsEndpoint => '${ApiConfig.baseUrl}/tournaments';
  static String _userTournamentsEndpoint(String userId) => '$_tournamentsEndpoint/user/$userId';
  static String _tournamentEndpoint(String id) => '$_tournamentsEndpoint/$id';

  // Create a new tournament
  static Future<Tournament> createTournament(Tournament tournament) async {
    try {
      final response = await http.post(
        Uri.parse(_tournamentsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tournament.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        return Tournament.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create tournament: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating tournament: $e');
    }
  }

  // Get all tournaments for a user
  static Future<List<Tournament>> getUserTournaments(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(_userTournamentsEndpoint(userId)),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tournament.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tournaments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading tournaments: $e');
    }
  }

  // Get a specific tournament
  static Future<Tournament> getTournament(String id) async {
    try {
      final response = await http.get(
        Uri.parse(_tournamentEndpoint(id)),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return Tournament.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load tournament: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading tournament: $e');
    }
  }

  // Update a tournament
  static Future<Tournament> updateTournament(Tournament tournament) async {
    try {
      if (tournament.id == null) {
        throw Exception('Tournament ID is required for update');
      }

      final response = await http.put(
        Uri.parse(_tournamentEndpoint(tournament.id!)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tournament.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return Tournament.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update tournament: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating tournament: $e');
    }
  }

  // Delete a tournament
  static Future<void> deleteTournament(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(_tournamentEndpoint(id)),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete tournament: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting tournament: $e');
    }
  }
}