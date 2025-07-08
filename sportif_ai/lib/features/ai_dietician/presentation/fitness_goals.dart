import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';

class FitnessGoal {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime targetDate;
  final GoalType type;
  final String targetValue;
  final String currentValue;
  final String unit;
  bool completed;

  FitnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.targetDate,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    this.completed = false,
  });

  double get progressPercentage {
    if (completed) return 1.0;
    
    try {
      final current = double.parse(currentValue);
      final target = double.parse(targetValue);
      
      if (type == GoalType.decrease) {
        // For weight loss or similar goals
        final initial = double.parse(initialValue ?? currentValue);
        if (initial == target) return 1.0; // Avoid division by zero
        final progress = (initial - current) / (initial - target);
        return progress.clamp(0.0, 1.0);
      } else {
        // For weight gain, muscle gain, etc.
        if (target == 0) return 1.0; // Avoid division by zero
        final progress = current / target;
        return progress.clamp(0.0, 1.0);
      }
    } catch (e) {
      return 0.0;
    }
  }

  String? initialValue;

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      type: GoalType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => GoalType.increase,
      ),
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      unit: json['unit'],
      completed: json['completed'] ?? false,
    )..initialValue = json['initialValue'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'type': type.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'completed': completed,
      'initialValue': initialValue,
    };
  }

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? targetDate,
    GoalType? type,
    String? targetValue,
    String? currentValue,
    String? unit,
    bool? completed,
    String? initialValue,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      completed: completed ?? this.completed,
    )..initialValue = initialValue ?? this.initialValue;
  }
}

enum GoalType {
  increase,
  decrease,
  maintain,
  complete,
}

class FitnessGoalsScreen extends StatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  State<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  List<FitnessGoal> _goals = [];
  bool _isLoading = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadGoals();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getStringList('fitness_goals') ?? [];
      
      final goals = goalsJson
          .map((json) => FitnessGoal.fromJson(Map<String, dynamic>.from(
              Map<String, dynamic>.from(jsonDecode(json) as Map))))
          .toList();

      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error loading goals, create sample goals
      _createSampleGoals();
    }
  }

  void _createSampleGoals() {
    final now = DateTime.now();
    final oneMonthLater = DateTime(now.year, now.month + 1, now.day);
    final twoMonthsLater = DateTime(now.year, now.month + 2, now.day);
    final threeMonthsLater = DateTime(now.year, now.month + 3, now.day);

    setState(() {
      _goals = [
        FitnessGoal(
          id: '1',
          title: 'Lose Weight',
          description: 'Reduce body weight through diet and exercise',
          startDate: now,
          targetDate: oneMonthLater,
          type: GoalType.decrease,
          targetValue: '70',
          currentValue: '75',
          unit: 'kg',
        )..initialValue = '80',
        FitnessGoal(
          id: '2',
          title: 'Increase Protein Intake',
          description: 'Consume more protein for muscle growth',
          startDate: now,
          targetDate: twoMonthsLater,
          type: GoalType.increase,
          targetValue: '120',
          currentValue: '80',
          unit: 'g/day',
        ),
        FitnessGoal(
          id: '3',
          title: 'Complete 30 Days of Hydration',
          description: 'Drink at least 2.5L of water every day for 30 days',
          startDate: now,
          targetDate: threeMonthsLater,
          type: GoalType.complete,
          targetValue: '30',
          currentValue: '10',
          unit: 'days',
        ),
      ];
      _isLoading = false;
    });

    _saveGoals();
  }

  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = _goals.map((goal) => jsonEncode(goal.toJson())).toList();
      await prefs.setStringList('fitness_goals', goalsJson);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goals: $e')),
      );
    }
  }

  void _addGoal(FitnessGoal goal) {
    setState(() {
      _goals.add(goal);
    });
    _saveGoals();
  }

  void _updateGoal(FitnessGoal updatedGoal) {
    setState(() {
      final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        final oldGoal = _goals[index];
        final wasCompleted = oldGoal.completed;
        _goals[index] = updatedGoal;
        
        // If the goal was just completed, show celebration
        if (!wasCompleted && updatedGoal.completed) {
          _confettiController.play();
        }
      }
    });
    _saveGoals();
  }

  void _deleteGoal(String id) {
    setState(() {
      _goals.removeWhere((goal) => goal.id == id);
    });
    _saveGoals();
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        onSave: _addGoal,
      ),
    );
  }

  void _showUpdateGoalDialog(FitnessGoal goal) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        goal: goal,
        onSave: _updateGoal,
      ),
    );
  }

  void _showUpdateProgressDialog(FitnessGoal goal) {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateDialog(
        goal: goal,
        onUpdate: _updateGoal,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Goals'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _goals.isEmpty
                  ? _buildEmptyState()
                  : _buildGoalsList(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Goal',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Fitness Goals Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set goals to track your fitness journey',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddGoalDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    final activeGoals = _goals.where((goal) => !goal.completed).toList();
    final completedGoals = _goals.where((goal) => goal.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Goals (${activeGoals.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (activeGoals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No active goals. Add a new goal to get started!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(activeGoals[index]);
              },
            ),
          const SizedBox(height: 24),
          if (completedGoals.isNotEmpty) ...[            
            Text(
              'Completed Goals (${completedGoals.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completedGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(completedGoals[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(FitnessGoal goal) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && !goal.completed;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getGoalTypeIcon(goal.type),
                  color: goal.completed
                      ? Colors.green
                      : isOverdue
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: goal.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (goal.completed)
                  const Chip(
                    label: Text('Completed'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                else if (isOverdue)
                  const Chip(
                    label: Text('Overdue'),
                    backgroundColor: Colors.red,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                else
                  Chip(
                    label: Text('$daysLeft days left'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(goal.description),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progressPercentage,
              backgroundColor: Colors.grey[200],
              color: goal.completed
                  ? Colors.green
                  : isOverdue
                      ? Colors.red
                      : Theme.of(context).primaryColor,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(goal.progressPercentage * 100).toInt()}% complete',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: ${dateFormat.format(goal.targetDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    if (!goal.completed)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUpdateGoalDialog(goal),
                        tooltip: 'Edit Goal',
                      ),
                    if (!goal.completed)
                      IconButton(
                        icon: const Icon(Icons.update),
                        onPressed: () => _showUpdateProgressDialog(goal),
                        tooltip: 'Update Progress',
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteGoal(goal.id),
                      tooltip: 'Delete Goal',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.increase:
        return Icons.trending_up;
      case GoalType.decrease:
        return Icons.trending_down;
      case GoalType.maintain:
        return Icons.trending_flat;
      case GoalType.complete:
        return Icons.check_circle;
    }
  }
}

class GoalFormDialog extends StatefulWidget {
  final FitnessGoal? goal;
  final Function(FitnessGoal) onSave;

  const GoalFormDialog({
    super.key,
    this.goal,
    required this.onSave,
  });

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;
  late TextEditingController _currentValueController;
  late TextEditingController _unitController;
  late DateTime _startDate;
  late DateTime _targetDate;
  late GoalType _goalType;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController = TextEditingController(text: goal?.description ?? '');
    _targetValueController = TextEditingController(text: goal?.targetValue ?? '');
    _currentValueController = TextEditingController(text: goal?.currentValue ?? '');
    _unitController = TextEditingController(text: goal?.unit ?? '');
    _startDate = goal?.startDate ?? DateTime.now();
    _targetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _goalType = goal?.type ?? GoalType.increase;
    _isCompleted = goal?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _targetDate,
      firstDate: isStartDate ? DateTime(2020) : _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure target date is not before start date
          if (_targetDate.isBefore(_startDate)) {
            _targetDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _targetDate = picked;
        }
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goal = FitnessGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        targetDate: _targetDate,
        type: _goalType,
        targetValue: _targetValueController.text,
        currentValue: _currentValueController.text,
        unit: _unitController.text,
        completed: _isCompleted,
      );
      
      if (widget.goal?.initialValue != null) {
        goal.initialValue = widget.goal!.initialValue;
      } else if (_goalType == GoalType.decrease) {
        // For decrease goals, set initial value if not already set
        goal.initialValue = _currentValueController.text;
      }
      
      widget.onSave(goal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Goal' : 'Add New Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Goal Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GoalType>(
                value: _goalType,
                decoration: const InputDecoration(labelText: 'Goal Type'),
                items: GoalType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getGoalTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _goalType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currentValueController,
                      decoration: const InputDecoration(labelText: 'Current Value'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _targetValueController,
                      decoration: const InputDecoration(labelText: 'Target Value'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit (kg, steps, etc.)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(_startDate)),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Target Date'),
                      subtitle: Text(DateFormat('MMM d, yyyy').format(_targetDate)),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              if (isEditing)
                CheckboxListTile(
                  title: const Text('Mark as Completed'),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  String _getGoalTypeText(GoalType type) {
    switch (type) {
      case GoalType.increase:
        return 'Increase (gain weight, build muscle, etc.)';
      case GoalType.decrease:
        return 'Decrease (lose weight, reduce body fat, etc.)';
      case GoalType.maintain:
        return 'Maintain (keep current level)';
      case GoalType.complete:
        return 'Complete (finish a challenge or task)';
    }
  }
}

class ProgressUpdateDialog extends StatefulWidget {
  final FitnessGoal goal;
  final Function(FitnessGoal) onUpdate;

  const ProgressUpdateDialog({
    super.key,
    required this.goal,
    required this.onUpdate,
  });

  @override
  State<ProgressUpdateDialog> createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<ProgressUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentValueController;
  bool _markAsCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentValueController = TextEditingController(text: widget.goal.currentValue);
  }

  @override
  void dispose() {
    _currentValueController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (_formKey.currentState!.validate()) {
      final updatedGoal = widget.goal.copyWith(
        currentValue: _currentValueController.text,
        completed: _markAsCompleted,
      );
      widget.onUpdate(updatedGoal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.goal.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currentValueController,
                    decoration: InputDecoration(
                      labelText: 'Current Value',
                      suffixText: widget.goal.unit,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target',
                      border: InputBorder.none,
                    ),
                    child: Text(
                      '${widget.goal.targetValue} ${widget.goal.unit}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Mark goal as completed'),
              value: _markAsCompleted,
              onChanged: (value) {
                setState(() {
                  _markAsCompleted = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateProgress,
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// Helper function to decode JSON
Map<String, dynamic> jsonDecode(String source) {
  // This is a placeholder. In a real app, you would use dart:convert's jsonDecode
  // For this example, we're creating a simple implementation
  try {
    // This is a very simplified version and won't handle all JSON cases
    final map = <String, dynamic>{};
    final trimmed = source.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      final content = trimmed.substring(1, trimmed.length - 1);
      final pairs = content.split(',');
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim().replaceAll('"', '');
          final value = keyValue[1].trim();
          if (value.startsWith('"') && value.endsWith('"')) {
            map[key] = value.substring(1, value.length - 1);
          } else if (value == 'true') {
            map[key] = true;
          } else if (value == 'false') {
            map[key] = false;
          } else if (value == 'null') {
            map[key] = null;
          } else if (int.tryParse(value) != null) {
            map[key] = int.parse(value);
          } else if (double.tryParse(value) != null) {
            map[key] = double.parse(value);
          } else {
            map[key] = value;
          }
        }
      }
    }
    return map;
  } catch (e) {
    return {};
  }
}