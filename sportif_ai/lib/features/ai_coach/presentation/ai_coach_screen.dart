import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:sportif_ai/config/api_config.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({Key? key}) : super(key: key);

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  String? _selectedSport;
  bool _isLoading = false;
  String? _lastDrillName;
  String? _lastDrillGrade;

  // Drill result data
  Map<String, dynamic>? _drillResult;

  @override
  void initState() {
    super.initState();
    _loadUserSport();
    _loadLastDrillResult();
  }

  void _loadUserSport() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null && user.sport != null) {
      setState(() {
        _selectedSport = user.sport;
      });
    }
  }

  Future<void> _loadLastDrillResult() async {
    // This would fetch the last drill result from the backend
    // For now, we'll just set a placeholder
    setState(() {
      _lastDrillName = 'Bowling Posture';
      _lastDrillGrade = 'Needs Improvement';
    });
  }

  Future<void> _startDrill(String drillName, {bool isBasic = true}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This would call the Python script via platform channel or HTTP
      // For now, we'll simulate a response
      await Future.delayed(const Duration(seconds: 2));

      // Simulate a response from the Python script
      final Map<String, dynamic> result = {
        'drill': drillName,
        'grade': _getRandomGrade(),
        'feedback': _getRandomFeedback(drillName, isBasic),
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _drillResult = result;
        _isLoading = false;
      });

      // Show the result modal
      _showDrillResultModal(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting drill: $e')),
      );
    }
  }

  String _getRandomGrade() {
    final grades = ['Excellent', 'Good', 'Needs Improvement'];
    return grades[DateTime.now().millisecond % grades.length];
  }

  List<String> _getRandomFeedback(String drillName, bool isBasic) {
    if (isBasic) {
      if (drillName == 'Squats') {
        return [
          'Knees not aligned with toes',
          'Back not straight during descent',
          'Not reaching proper depth',
        ];
      } else if (drillName == 'Push-ups') {
        return [
          'Elbows flaring out too much',
          'Hips sagging during movement',
          'Incomplete range of motion',
        ];
      } else {
        return [
          'Posture needs improvement',
          'Movement too fast',
          'Breathing pattern irregular',
        ];
      }
    } else {
      // Sport-specific feedback
      if (_selectedSport == 'Cricket') {
        if (drillName == 'Front Foot Drive') {
          return [
            'Head position not over front foot',
            'Bat swing not straight',
            'Weight transfer incomplete',
          ];
        } else if (drillName == 'Pull Shot') {
          return [
            'Not getting into position early',
            'Head falling to off side',
            'Bottom hand dominating too much',
          ];
        } else {
          return [
            'Wrist position incorrect',
            'Follow-through incomplete',
            'Balance not maintained',
          ];
        }
      } else if (_selectedSport == 'Badminton') {
        if (drillName == 'Smash Form') {
          return [
            'Wrist snap not powerful enough',
            'Racket preparation too late',
            'Jump timing off',
          ];
        } else if (drillName == 'Service Posture') {
          return [
            'Racket head too low',
            'Weight not transferring forward',
            'Shuttle release inconsistent',
          ];
        } else {
          return [
            'Footwork needs improvement',
            'Racket grip changing mid-stroke',
            'Follow-through cutting short',
          ];
        }
      } else {
        return [
          'Technique needs refinement',
          'Timing could be improved',
          'Balance not maintained throughout',
        ];
      }
    }
  }

  Future<void> _saveDrillResult(Map<String, dynamic> result) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/drill-results'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": user.uid,
          "sport": _selectedSport ?? 'General',
          "drill": result['drill'],
          "grade": result['grade'],
          "feedback": result['feedback'],
          "date": result['timestamp'],
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 201) {
        throw Exception("Failed to save drill result: ${response.body}");
      }

      // Update last drill info
      setState(() {
        _lastDrillName = result['drill'];
        _lastDrillGrade = result['grade'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drill result saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving drill result: $e')),
      );
    }
  }

  void _showDrillResultModal(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    result['drill'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildGradeIndicator(result['grade']),
              const SizedBox(height: 24),
              const Text(
                'Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...(result['feedback'] as List<String>).map((feedback) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feedback)),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _saveDrillResult(result);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Feedback'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradeIndicator(String grade) {
    Color color;
    IconData icon;

    switch (grade) {
      case 'Excellent':
        color = Colors.green;
        icon = Icons.sentiment_very_satisfied;
        break;
      case 'Good':
        color = Colors.amber;
        icon = Icons.sentiment_satisfied;
        break;
      case 'Needs Improvement':
        color = Colors.red;
        icon = Icons.sentiment_dissatisfied;
        break;
      default:
        color = Colors.grey;
        icon = Icons.sentiment_neutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            grade,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last drill feedback summary (optional)
                  if (_lastDrillName != null && _lastDrillGrade != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _lastDrillGrade == 'Excellent'
                                ? Icons.sentiment_very_satisfied
                                : _lastDrillGrade == 'Good'
                                    ? Icons.sentiment_satisfied
                                    : Icons.sentiment_dissatisfied,
                            color: _lastDrillGrade == 'Excellent'
                                ? Colors.green
                                : _lastDrillGrade == 'Good'
                                    ? Colors.amber
                                    : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Last drill: $_lastDrillName - $_lastDrillGrade',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Basic Drills Section
                  const Text(
                    'Basic Drills',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      _buildDrillCard(
                        title: 'Squats',
                        icon: FontAwesomeIcons.dumbbell,
                        color: Colors.blue,
                        onTap: () => _startDrill('Squats'),
                      ),
                      _buildDrillCard(
                        title: 'Push-ups',
                        icon: FontAwesomeIcons.handBackFist,
                        color: Colors.red,
                        onTap: () => _startDrill('Push-ups'),
                      ),
                      _buildDrillCard(
                        title: 'Jumping Jacks',
                        icon: FontAwesomeIcons.personRunning,
                        color: Colors.green,
                        onTap: () => _startDrill('Jumping Jacks'),
                      ),
                      _buildDrillCard(
                        title: 'Lunges',
                        icon: FontAwesomeIcons.personWalking,
                        color: Colors.purple,
                        onTap: () => _startDrill('Lunges'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Intermediate Drills Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Intermediate Drills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (_selectedSport != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E3192).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _selectedSport!,
                            style: const TextStyle(
                              color: Color(0xFF2E3192),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedSport == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.amber),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Please select a sport in your profile to see sport-specific drills.',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                      children: _buildSportSpecificDrills(),
                    ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildSportSpecificDrills() {
    if (_selectedSport == 'Cricket') {
      return [
        _buildDrillCard(
          title: 'Front Foot Drive',
          icon: FontAwesomeIcons.baseball,
          color: Colors.orange,
          onTap: () => _startDrill('Front Foot Drive', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Pull Shot',
          icon: FontAwesomeIcons.baseballBatBall,
          color: Colors.teal,
          onTap: () => _startDrill('Pull Shot', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Bowling Posture',
          icon: FontAwesomeIcons.personWalking,
          color: Colors.indigo,
          onTap: () => _startDrill('Bowling Posture', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Fielding Stance',
          icon: FontAwesomeIcons.handBackFist,
          color: Colors.brown,
          onTap: () => _startDrill('Fielding Stance', isBasic: false),
        ),
      ];
    } else if (_selectedSport == 'Badminton') {
      return [
        _buildDrillCard(
          title: 'Smash Form',
          icon: FontAwesomeIcons.tableTennis,
          color: Colors.pink,
          onTap: () => _startDrill('Smash Form', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Service Posture',
          icon: FontAwesomeIcons.handPeace,
          color: Colors.cyan,
          onTap: () => _startDrill('Service Posture', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Backhand Clear',
          icon: FontAwesomeIcons.handFist,
          color: Colors.deepPurple,
          onTap: () => _startDrill('Backhand Clear', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Net Play',
          icon: FontAwesomeIcons.tableTennisPaddleBall,
          color: Colors.lightBlue,
          onTap: () => _startDrill('Net Play', isBasic: false),
        ),
      ];
    } else {
      // Default drills for other sports
      return [
        _buildDrillCard(
          title: 'Sport Stance',
          icon: FontAwesomeIcons.personRunning,
          color: Colors.amber,
          onTap: () => _startDrill('Sport Stance', isBasic: false),
        ),
        _buildDrillCard(
          title: 'Basic Form',
          icon: FontAwesomeIcons.personWalking,
          color: Colors.deepOrange,
          onTap: () => _startDrill('Basic Form', isBasic: false),
        ),
      ];
    }
  }

  Widget _buildDrillCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}