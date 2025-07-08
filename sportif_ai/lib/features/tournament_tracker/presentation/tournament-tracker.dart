import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sportif_ai/core/models/tournament_model.dart';
import 'package:sportif_ai/core/services/tournament_service.dart';
import 'package:sportif_ai/core/services/firebase_service.dart';

class TournamentTrackerScreen extends StatefulWidget {
  const TournamentTrackerScreen({super.key});

  @override
  State<TournamentTrackerScreen> createState() => _TournamentTrackerScreenState();
}

class _TournamentTrackerScreenState extends State<TournamentTrackerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _errorMessage;

  final List<Tournament> _tournaments = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = FirebaseService().currentUser;
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });
        _loadTournaments();
      } else {
        setState(() {
          _errorMessage = 'Please sign in to view your tournaments';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting current user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTournaments() async {
    if (_currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tournaments = await TournamentService.getUserTournaments(_currentUserId!);
      setState(() {
        _tournaments.clear();
        _tournaments.addAll(tournaments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading tournaments: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTournament(Tournament tournament) async {
    try {
      final savedTournament = await TournamentService.createTournament(tournament);
      setState(() {
        _tournaments.add(savedTournament);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving tournament: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Tracker'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8fafc), Color(0xFFe0e7ef)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {CalendarFormat.month: 'Month'},
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
                        color: const Color(0xFF4f8cff),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.18),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFffb347),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.18),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.25),
                            blurRadius: 4,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 3,
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFFe57373),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                      defaultTextStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF22223b),
                      ),
                      withinRangeTextStyle: TextStyle(
                        color: Colors.blueGrey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                      disabledTextStyle: const TextStyle(
                        color: Color(0xFFbfc0c0),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(
                        color: Color(0xFFe57373),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                      ),
                      weekdayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF22223b),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF4f8cff),
                        letterSpacing: 1.1,
                      ),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF4f8cff), size: 28),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF4f8cff), size: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe3f0ff),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    eventLoader: (day) => _getEventsForDay(day),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: Color(0xFF22223b),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              color: Color(0xFFbfc0c0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                events.length > 3 ? 3 : events.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.25),
                                        blurRadius: 4,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(_errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadTournaments,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final events = _getEventsForDay(_selectedDay ?? DateTime.now());
                  if (events.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('No tournaments scheduled for this day.',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final tournament = events[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.primary),
                          title: Text(tournament.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${tournament.formattedDate}\n${tournament.description}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTournament(tournament),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _deleteTournament(Tournament tournament) async {
    try {
      if (tournament.id != null) {
        await TournamentService.deleteTournament(tournament.id!);
        setState(() {
          _tournaments.remove(tournament);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting tournament: $e')),
      );
    }
  }

  void _showAddEventSheet() {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to add tournaments')),
      );
      return;
    }
    
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    DateTime? date = _selectedDay ?? DateTime.now();
    TimeOfDay? time = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Event', style: Theme.of(context).textTheme.titleLarge),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Event Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter event name' : null,
                    onSaved: (val) => name = val ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                    onSaved: (val) => description = val ?? '',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date!,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              date = picked;
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Date'),
                            child: Text(DateFormat('MMM dd, yyyy').format(date!)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time!,
                            );
                            if (picked != null) {
                              time = picked;
                              (context as Element).markNeedsBuild();
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Time'),
                            child: Text(time!.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final eventDateTime = DateTime(
                          date!.year,
                          date!.month,
                          date!.day,
                          time!.hour,
                          time!.minute,
                        );
                        final newTournament = Tournament(
                          name: name,
                          description: description,
                          date: eventDateTime,
                          userId: _currentUserId!,
                        );
                        _saveTournament(newTournament);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Event'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper: Get events for a given day
  List<Tournament> _getEventsForDay(DateTime day) {
    return _tournaments.where((event) => isSameDay(event.date, day)).toList();
  }
}

