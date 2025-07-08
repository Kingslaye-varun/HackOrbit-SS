import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TournamentTrackerScreen extends StatefulWidget {
  const TournamentTrackerScreen({super.key});

  @override
  State<TournamentTrackerScreen> createState() => _TournamentTrackerScreenState();
}

class _TournamentTrackerScreenState extends State<TournamentTrackerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, dynamic>> _tournaments = [
    {
      'name': 'Local Championship',
      'date': DateTime.now().add(const Duration(days: 3)),
      'location': 'Main Stadium',
      'participants': 24,
    },
    {
      'name': 'Regional Finals',
      'date': DateTime.now().add(const Duration(days: 10)),
      'location': 'City Arena',
      'participants': 16,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tournaments.length,
              itemBuilder: (context, index) {
                final tournament = _tournaments[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(tournament['name']),
                    subtitle: Text(
                      '${DateFormat('MMM dd, yyyy').format(tournament['date'])} • ${tournament['location']}',
                    ),
                    trailing: Chip(
                      label: Text('${tournament['participants']} players'),
                    ),
                    onTap: () {
                      // Handle tournament selection
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new tournament
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}