import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/features/ai_coach/data/repositories/ai_coach_repository.dart';
import 'package:sportif_ai/features/ai_coach/domain/models/drill_result.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';

class DrillHistoryScreen extends StatefulWidget {
  const DrillHistoryScreen({super.key});

  @override
  State<DrillHistoryScreen> createState() => _DrillHistoryScreenState();
}

class _DrillHistoryScreenState extends State<DrillHistoryScreen> {
  bool _isLoading = true;
  List<DrillResult> _drillResults = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDrillHistory();
  }

  Future<void> _loadDrillHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated';
      });
      return;
    }

    try {
      final repository = AiCoachRepository();
      final results = await repository.getUserDrillResults(userId);
      
      setState(() {
        _drillResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load drill history: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _drillResults.isEmpty
                  ? const Center(child: Text('No drill history found'))
                  : _buildDrillHistoryList(),
    );
  }

  Widget _buildDrillHistoryList() {
    // Group drill results by date
    final Map<String, List<DrillResult>> groupedResults = {};
    
    for (final result in _drillResults) {
      if (!groupedResults.containsKey(result.date)) {
        groupedResults[result.date] = [];
      }
      groupedResults[result.date]!.add(result);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedResults.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateResults = groupedResults[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ...dateResults.map((result) => _buildDrillResultCard(result)).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildDrillResultCard(DrillResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    result.drill,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildGradeIndicator(result.grade),
              ],
            ),
            const SizedBox(height: 8),
            Text('Sport: ${result.sport}'),
            const SizedBox(height: 8),
            const Text(
              'Feedback:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...result.feedback.map(
              (feedback) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(feedback)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeIndicator(String grade) {
    Color color;
    IconData icon;

    switch (grade) {
      case 'Excellent':
        color = Colors.green;
        icon = Icons.star;
        break;
      case 'Good':
        color = Colors.blue;
        icon = Icons.thumb_up;
        break;
      case 'Needs Improvement':
        color = Colors.orange;
        icon = Icons.build;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            grade,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}