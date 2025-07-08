// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Achievement {
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final Color color;
  final String category;

  Achievement({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> achievements = [
    Achievement(
      title: 'First Victory',
      description: 'Won your first tournament match',
      date: '2025-01-15',
      icon: FontAwesomeIcons.trophy,
      color: Colors.amber,
      category: 'Tournament',
    ),
    Achievement(
      title: 'Training Streak',
      description: 'Completed 7 consecutive training sessions',
      date: '2025-02-10',
      icon: FontAwesomeIcons.fire,
      color: Colors.orange,
      category: 'Training',
    ),
    Achievement(
      title: 'Personal Best',
      description: 'Achieved new personal record in 100m sprint',
      date: '2025-03-05',
      icon: FontAwesomeIcons.medal,
      color: Colors.blue,
      category: 'Performance',
    ),
  ];

  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Tournament', 'Training', 'Performance', 'Health'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF2E3192),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAchievementDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildAchievementsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF6A5ACD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.trophy,
            label: 'Total',
            value: '${achievements.length}',
          ),
          _buildStatItem(
            icon: FontAwesomeIcons.calendar,
            label: 'This Month',
            value: '2',
          ),
          _buildStatItem(
            icon: FontAwesomeIcons.star,
            label: 'Recent',
            value: '1',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2E3192).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF2E3192) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsList() {
    final filteredAchievements = selectedCategory == 'All'
        ? achievements
        : achievements.where((a) => a.category == selectedCategory).toList();

    if (filteredAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.trophy,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No achievements yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first achievement to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: achievement.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: achievement.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          achievement.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: achievement.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        achievement.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAchievementDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Tournament';
    IconData selectedIcon = FontAwesomeIcons.trophy;
    Color selectedColor = Colors.amber;

    final Map<String, Map<String, dynamic>> categoryData = {
      'Tournament': {'icon': FontAwesomeIcons.trophy, 'color': Colors.amber},
      'Training': {'icon': FontAwesomeIcons.fire, 'color': Colors.orange},
      'Performance': {'icon': FontAwesomeIcons.medal, 'color': Colors.blue},
      'Health': {'icon': FontAwesomeIcons.heart, 'color': Colors.red},
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Achievement'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Achievement Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryData.keys.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                categoryData[category]!['icon'],
                                color: categoryData[category]!['color'],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedCategory = value!;
                          selectedIcon = categoryData[value]!['icon'];
                          selectedColor = categoryData[value]!['color'];
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
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      final newAchievement = Achievement(
                        title: titleController.text,
                        description: descriptionController.text,
                        date: DateTime.now().toString().split(' ')[0],
                        icon: selectedIcon,
                        color: selectedColor,
                        category: selectedCategory,
                      );
                      
                      setState(() {
                        achievements.add(newAchievement);
                      });
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Achievement added successfully!'),
                          backgroundColor: Color(0xFF2E3192),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}