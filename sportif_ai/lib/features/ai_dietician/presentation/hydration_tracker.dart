import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HydrationTracker extends StatefulWidget {
  const HydrationTracker({super.key});

  @override
  State<HydrationTracker> createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<HydrationTracker> {
  final int _targetWaterIntake = 2500; // ml per day
  int _currentWaterIntake = 0;
  List<WaterLog> _waterLogs = [];
  Timer? _reminderTimer;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _initNotifications();
    _setupReminderTimer();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateString(DateTime.now());
    
    setState(() {
      _currentWaterIntake = prefs.getInt('water_intake_$today') ?? 0;
      
      // Load water logs
      final logsJson = prefs.getStringList('water_logs_$today') ?? [];
      _waterLogs = logsJson.map((json) => WaterLog.fromJson(json)).toList();
    });
  }

  Future<void> _saveWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateString(DateTime.now());
    
    await prefs.setInt('water_intake_$today', _currentWaterIntake);
    
    // Save water logs
    final logsJson = _waterLogs.map((log) => log.toJson()).toList();
    await prefs.setStringList('water_logs_$today', logsJson);
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  void _setupReminderTimer() {
    // Check if user has enabled hydration reminders
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null && user.hydrationReminder) {
      // Set up a timer to remind every hour
      _reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) {
        _showHydrationReminder();
      });
    }
  }

  Future<void> _showHydrationReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Reminders',
      channelDescription: 'Reminders to drink water throughout the day',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Hydration Reminder',
      'Time to drink some water! Stay hydrated for better performance.',
      platformChannelSpecifics,
    );
  }

  void _addWater(int amount) {
    setState(() {
      _currentWaterIntake += amount;
      _waterLogs.add(
        WaterLog(
          amount: amount,
          timestamp: DateTime.now(),
        ),
      );
    });
    _saveWaterIntake();
  }

  void _resetWaterIntake() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Water Intake'),
        content: const Text('Are you sure you want to reset your water intake for today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentWaterIntake = 0;
                _waterLogs = [];
              });
              _saveWaterIntake();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Water intake reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
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

    final double progress = _currentWaterIntake / _targetWaterIntake;
    final bool isHydrationReminderEnabled = user.hydrationReminder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hydration Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetWaterIntake,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Daily Water Intake',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: CircularProgressIndicator(
                            value: progress > 1.0 ? 1.0 : progress,
                            strokeWidth: 15,
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            color: _getProgressColor(progress),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '${_currentWaterIntake}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'ml',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'of $_targetWaterIntake ml',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterButton(100, Icons.water_drop),
                        _buildWaterButton(250, Icons.water),
                        _buildWaterButton(500, Icons.water_drop),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Hydration Reminders'),
                      subtitle: const Text('Receive hourly reminders to drink water'),
                      value: isHydrationReminderEnabled,
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
            const SizedBox(height: 24),
            const Text(
              'Today\'s Hydration Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _waterLogs.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No water intake logged today. Start drinking!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _waterLogs.length,
                      itemBuilder: (context, index) {
                        final log = _waterLogs[_waterLogs.length - 1 - index]; // Reverse order
                        return ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.blue),
                          title: Text('${log.amount} ml'),
                          subtitle: Text(_formatTime(log.timestamp)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _currentWaterIntake -= log.amount;
                                if (_currentWaterIntake < 0) _currentWaterIntake = 0;
                                _waterLogs.removeAt(_waterLogs.length - 1 - index);
                              });
                              _saveWaterIntake();
                            },
                          ),
                        );
                      },
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
                      'Hydration Tips',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem(
                      'Drink water before, during, and after exercise',
                      Icons.fitness_center,
                    ),
                    _buildTipItem(
                      'Carry a water bottle with you throughout the day',
                      Icons.local_drink,
                    ),
                    _buildTipItem(
                      'Set reminders to drink water regularly',
                      Icons.alarm,
                    ),
                    _buildTipItem(
                      'Eat water-rich fruits and vegetables',
                      Icons.restaurant,
                    ),
                    _buildTipItem(
                      'Monitor your urine color - pale yellow is ideal',
                      Icons.colorize,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomWaterDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add custom amount',
      ),
    );
  }

  Widget _buildWaterButton(int amount, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _addWater(amount),
      icon: Icon(icon),
      label: Text('$amount ml'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }

  void _showCustomWaterDialog() {
    int customAmount = 0;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onSaved: (value) {
              customAmount = int.parse(value!);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                _addWater(customAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return Colors.red;
    } else if (progress < 0.75) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class WaterLog {
  final int amount;
  final DateTime timestamp;

  WaterLog({
    required this.amount,
    required this.timestamp,
  });

  factory WaterLog.fromJson(String json) {
    final parts = json.split('|');
    return WaterLog(
      amount: int.parse(parts[0]),
      timestamp: DateTime.parse(parts[1]),
    );
  }

  String toJson() {
    return '$amount|${timestamp.toIso8601String()}';
  }
}