import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/features/Scout_players/player_model.dart';
import 'package:sportif_ai/core/models/user_model.dart';

class PlayerService {
  // ApiConfig is a utility class with static methods, no need to instantiate

  // Fetch all players from the backend
  Future<List<Player>> fetchPlayers() async {
    try {
      final url = Uri.parse(ApiConfig.usersEndpoint);
      print('Fetching players from: $url');
      
      final response = await http.get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Successfully fetched players');
        final List<dynamic> data = json.decode(response.body);
        final List<Player> fetchedPlayers = data.map((userData) => _convertUserToPlayer(userData)).toList();
        
        if (fetchedPlayers.isEmpty) {
          print('No players found in the database, returning sample data');
          return players;
        }
        
        print('Converted ${fetchedPlayers.length} players from user data');
        return fetchedPlayers;
      } else {
        print('Failed to load players: ${response.statusCode}');
        // Return sample data if API fails
        return players;
      }
    } catch (e) {
      print('Error fetching players: $e');
      // Return sample data if API fails
      return players;
    }
  }

  // Convert user data from backend to Player model
  Player _convertUserToPlayer(Map<String, dynamic> userData) {
    // Convert to UserModel first
    final user = UserModel.fromJson(userData);
    
    // Create a random number generator with a seed based on the user's uid
    // This ensures the same user always gets the same random attributes
    final random = Random(user.uid.hashCode);
    
    // Generate consistent attributes for this user
    final attributes = PlayerAttributes(
      speed: 60 + random.nextInt(36),
      strength: 60 + random.nextInt(36),
      iq: 60 + random.nextInt(36),
      teamwork: 60 + random.nextInt(36),
      specialSkill: _getRandomSpecialSkill(user.sport, random),
    );

    // Generate a position based on the sport
    final position = _getPositionForSport(user.sport, random);
    
    // Calculate overall rating based on attributes
    final overallRating = (3.5 + (attributes.speed + attributes.strength + attributes.iq + attributes.teamwork) / 400).clamp(3.0, 5.0);
    
    return Player(
      name: user.name,
      sport: user.sport ?? 'Unknown Sport',
      position: position,
      role: _getRoleForPosition(position),
      overallRating: overallRating,
      attributes: attributes,
      certificates: _generateRandomCertificates(user.sport, random),
      imageUrl: user.photoUrl,
      email: user.email,
      phoneNumber: user.phoneNumber,
      age: user.age != null ? user.age.toString() : 'Unknown',
    );
  }

  // Get a random special skill based on sport
  String? _getRandomSpecialSkill(String? sport, Random random) {
    if (sport == null) return null;
    
    final Map<String, List<String>> sportSkills = {
      'Cricket': ['Fast Bowling', 'Spin Bowling', 'Power Hitting', 'Fielding'],
      'Football': ['Free Kicks', 'Dribbling', 'Heading', 'Long Pass'],
      'Basketball': ['3-Point Shooting', 'Dunking', 'Ball Handling', 'Shot Blocking'],
      'Tennis': ['Serve', 'Backhand', 'Forehand', 'Volley'],
      'Volleyball': ['Spiking', 'Blocking', 'Setting', 'Serving'],
    };
    
    final skills = sportSkills[sport] ?? ['Athletic'];
    return skills[random.nextInt(skills.length)];
  }

  // Get position based on sport
  String _getPositionForSport(String? sport, Random random) {
    if (sport == null) return 'Player';
    
    final Map<String, List<String>> sportPositions = {
      'Cricket': ['Batsman', 'Bowler', 'All-rounder', 'Wicket Keeper'],
      'Football': ['Forward', 'Midfielder', 'Defender', 'Goalkeeper'],
      'Basketball': ['Point Guard', 'Shooting Guard', 'Small Forward', 'Power Forward', 'Center'],
      'Tennis': ['Singles', 'Doubles'],
      'Volleyball': ['Setter', 'Outside Hitter', 'Middle Blocker', 'Libero'],
    };
    
    final positions = sportPositions[sport] ?? ['Player'];
    return positions[random.nextInt(positions.length)];
  }

  // Get role based on position
  String? _getRoleForPosition(String position) {
    final Map<String, String> positionRoles = {
      'Batsman': 'Top Order',
      'Bowler': 'Fast Bowler',
      'All-rounder': 'Batting All-rounder',
      'Wicket Keeper': 'Wicket Keeper-Batsman',
      'Forward': 'Striker',
      'Midfielder': 'Attacking Midfielder',
      'Defender': 'Center Back',
      'Goalkeeper': 'Shot Stopper',
      'Point Guard': 'Playmaker',
      'Shooting Guard': 'Scorer',
      'Small Forward': 'Wing Player',
      'Power Forward': 'Post Player',
      'Center': 'Defensive Anchor',
      'Singles': 'Baseline Player',
      'Doubles': 'Net Player',
      'Setter': 'Playmaker',
      'Outside Hitter': 'Scorer',
      'Middle Blocker': 'Blocker',
      'Libero': 'Defensive Specialist',
    };
    
    return positionRoles[position];
  }

  // Generate random certificates based on sport
  List<String> _generateRandomCertificates(String? sport, Random random) {
    if (sport == null) return [];
    
    final Map<String, List<String>> sportCertificates = {
      'Cricket': ['ICC Youth Certificate', 'National Cricket Academy', 'Regional MVP'],
      'Football': ['FIFA Youth Certificate', 'Elite Youth Program', 'Regional Championship'],
      'Basketball': ['National Basketball Academy', 'State Championship', 'All-Star Selection'],
      'Tennis': ['ITF Junior Champion', 'National Tennis Academy', 'Regional Tournament Winner'],
      'Volleyball': ['National Volleyball Certificate', 'State Championship', 'MVP Award'],
    };
    
    final certificates = sportCertificates[sport] ?? ['Sports Excellence Certificate'];
    final numCertificates = 1 + random.nextInt(2); // 1 or 2 certificates
    final selectedCertificates = <String>[];
    
    // Shuffle the certificates list to get random ones
    final shuffledCertificates = List<String>.from(certificates);
    shuffledCertificates.shuffle(random);
    
    for (int i = 0; i < numCertificates && i < shuffledCertificates.length; i++) {
      selectedCertificates.add(shuffledCertificates[i]);
    }
    
    return selectedCertificates;
  }
}