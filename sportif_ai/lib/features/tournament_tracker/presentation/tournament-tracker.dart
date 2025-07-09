import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    // This will be loaded from storage
  ];

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tournaments');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        _tournaments.clear();
        _tournaments.addAll(decoded.map((e) => {
          'name': e['name'],
          'description': e['description'],
          'date': DateTime.parse(e['date']),
        }));
      });
    } else {
      // Optionally, add some sample data if empty
      setState(() {
        _tournaments.addAll([
          {
            'name': 'Local Championship',
            'date': DateTime.now().add(const Duration(days: 3)),
            'description': 'A local tournament.',
          },
          {
            'name': 'Regional Finals',
            'date': DateTime.now().add(const Duration(days: 10)),
            'description': 'Regional level finals.',
          },
        ]);
      });
    }
  }

  Future<void> _saveTournaments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_tournaments.map((e) => {
      'name': e['name'],
      'description': e['description'],
      'date': (e['date'] as DateTime).toIso8601String(),
    }).toList());
    await prefs.setString('tournaments', data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Tournament Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                // Add filter or settings functionality here
              },
              icon: const Icon(Icons.filter_list_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Events',
                    '${_tournaments.length}',
                    Icons.emoji_events_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    'This Month',
                    '${_getEventsForMonth(DateTime.now()).length}',
                    Icons.calendar_month_rounded,
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
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
                        color: const Color(0xFF6366F1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFEC4899),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 3,
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFFEC4899),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      defaultTextStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                      disabledTextStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(
                        color: Color(0xFFEC4899),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      weekdayStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                      headerMargin: const EdgeInsets.only(bottom: 16),
                    ),
                    eventLoader: (day) => _getEventsForDay(day),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          return Positioned(
                            bottom: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                events.length > 3 ? 3 : events.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
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
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Events List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDay != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateFormat('MMM dd').format(_selectedDay!),
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final events = _getEventsForDay(_selectedDay ?? DateTime.now());
                        if (events.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.event_busy_rounded,
                                    size: 48,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No tournaments scheduled',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'for ${_selectedDay != null ? DateFormat('MMM dd, yyyy').format(_selectedDay!) : 'today'}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          itemCount: events.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tournament = events[index];
                            return _buildTournamentCard(tournament);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddEventSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentCard(Map<String, dynamic> tournament) {
    final now = DateTime.now();
    final tournamentDate = tournament['date'] as DateTime;
    final isToday = isSameDay(tournamentDate, now);
    final isPast = tournamentDate.isBefore(now);
    final isUpcoming = tournamentDate.isAfter(now);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isToday) {
      statusColor = const Color(0xFFEC4899);
      statusText = 'Today';
      statusIcon = Icons.today_rounded;
    } else if (isPast) {
      statusColor = const Color(0xFF64748B);
      statusText = 'Past';
      statusIcon = Icons.history_rounded;
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = 'Upcoming';
      statusIcon = Icons.upcoming_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy – hh:mm a').format(tournamentDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tournament['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForMonth(DateTime month) {
    return _tournaments.where((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.year == month.year && eventDate.month == month.month;
    }).toList();
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddEventSheet() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    DateTime? date = _selectedDay ?? DateTime.now();
    TimeOfDay? time = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Color(0xFF6366F1),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Add New Event',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Event Name',
                            prefixIcon: const Icon(Icons.event_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6366F1)),
                            ),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Enter event name' : null,
                          onSaved: (val) => name = val ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF6366F1)),
                            ),
                          ),
                          maxLines: 3,
                          validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                          onSaved: (val) => description = val ?? '',
                        ),
                        const SizedBox(height: 16),
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
                                    setModalState(() {});
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 20),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM dd, yyyy').format(date!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                    setModalState(() {});
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 20),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Time',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            time!.format(context),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                                setState(() {
                                  _tournaments.add({
                                    'name': name,
                                    'description': description,
                                    'date': eventDateTime,
                                  });
                                });
                                _saveTournaments();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Event',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper: Get events for a given day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _tournaments.where((event) => isSameDay(event['date'], day)).toList();
  }
}