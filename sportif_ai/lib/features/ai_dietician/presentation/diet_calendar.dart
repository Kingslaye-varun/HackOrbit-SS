import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';

class DietEvent {
  final String title;
  final String description;
  final String mealType; // breakfast, lunch, dinner, snack
  final int calories;
  final DateTime date;
  final bool completed;

  DietEvent({
    required this.title,
    required this.description,
    required this.mealType,
    required this.calories,
    required this.date,
    this.completed = false,
  });
}

class DietCalendar extends StatefulWidget {
  const DietCalendar({super.key});

  @override
  State<DietCalendar> createState() => _DietCalendarState();
}

class _DietCalendarState extends State<DietCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<DietEvent>> _events;
  late List<DietEvent> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _selectedEvents = _getEventsForDay(_selectedDay);
    _loadEvents();
  }

  void _loadEvents() {
    // In a real app, this would load events from a database or API
    // For now, we'll create some sample events
    final today = DateTime.now();
    final Map<DateTime, List<DietEvent>> events = {};

    // Create sample events for the current week
    for (int i = -3; i <= 3; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      events[day] = [
        DietEvent(
          title: 'Breakfast',
          description: 'Oatmeal with fruits',
          mealType: 'breakfast',
          calories: 300,
          date: DateTime(day.year, day.month, day.day, 8, 0),
          completed: i < 0, // Past events are completed
        ),
        DietEvent(
          title: 'Lunch',
          description: 'Grilled chicken salad',
          mealType: 'lunch',
          calories: 450,
          date: DateTime(day.year, day.month, day.day, 13, 0),
          completed: i < 0,
        ),
        DietEvent(
          title: 'Dinner',
          description: 'Salmon with vegetables',
          mealType: 'dinner',
          calories: 500,
          date: DateTime(day.year, day.month, day.day, 19, 0),
          completed: i < 0,
        ),
        DietEvent(
          title: 'Snack',
          description: 'Greek yogurt with nuts',
          mealType: 'snack',
          calories: 200,
          date: DateTime(day.year, day.month, day.day, 16, 0),
          completed: i < 0,
        ),
      ];
    }

    setState(() {
      _events = events;
      _selectedEvents = _getEventsForDay(_selectedDay);
    });
  }

  List<DietEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
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
        title: const Text('Diet Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<DietEvent>(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Meal',
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_meals, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No meals planned for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddEventDialog,
              child: const Text('Add Meal'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: _getMealTypeIcon(event.mealType),
            title: Text(event.title),
            subtitle: Text(event.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${event.calories} kcal',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: event.completed,
                  onChanged: (bool? value) {
                    // In a real app, this would update the event in the database
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal status updated')),
                    );
                  },
                ),
              ],
            ),
            onTap: () => _showEventDetails(event),
          ),
        );
      },
    );
  }

  Widget _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.free_breakfast, color: Colors.white),
        );
      case 'lunch':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.lunch_dining, color: Colors.white),
        );
      case 'dinner':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.dinner_dining, color: Colors.white),
        );
      case 'snack':
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.apple, color: Colors.white),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.restaurant, color: Colors.white),
        );
    }
  }

  void _showEventDetails(DietEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getMealTypeIcon(event.mealType),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${event.calories} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would mark the meal as completed
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meal marked as completed')),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Complete'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // In a real app, this would edit the meal
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEventDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String mealType = 'breakfast';
    int calories = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Meal'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: mealType,
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                    items: const [
                      DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'snack', child: Text('Snack')),
                    ],
                    onChanged: (value) {
                      mealType = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      title = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter calories';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      calories = int.parse(value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  // In a real app, this would save the event to a database
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal added to calendar')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}