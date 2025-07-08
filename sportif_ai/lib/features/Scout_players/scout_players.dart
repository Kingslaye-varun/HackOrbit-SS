import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sportif_ai/routes/app_routes.dart';
import 'package:sportif_ai/features/Scout_players/player_model.dart';

class ScoutPlayersScreen extends StatelessWidget {
  const ScoutPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout Players'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return _buildPlayerCard(players[index], context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search players...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onChanged: (value) {
        // Implement search functionality
      },
    );
  }

  Widget _buildPlayerCard(Player player, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          AppRoutes.navigateToPlayerDetails(context, player);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayerAvatar(player),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${player.sport} • ${player.position}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSkillRating(player.overallRating),
                      ],
                    ),
                  ),
                  _buildFavoriteButton(),
                ],
              ),
              const SizedBox(height: 12),
              _buildPlayerAttributes(player),
              if (player.certificates.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildCertificates(player.certificates),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(Player player) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        image: player.imageUrl != null 
            ? DecorationImage(
                image: NetworkImage(player.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: player.imageUrl == null
          ? const Icon(Icons.person, size: 30, color: Colors.grey)
          : null,
    );
  }

  Widget _buildSkillRating(double rating) {
    return Row(
      children: [
        _buildRatingStars(rating),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: const Icon(Icons.favorite_border),
      color: Colors.grey,
      onPressed: () {
        // Toggle favorite status
      },
    );
  }

  Widget _buildPlayerAttributes(Player player) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildAttributeChip(
          icon: FontAwesomeIcons.running,
          label: 'Speed: ${player.attributes.speed}',
          color: Colors.blue,
        ),
        _buildAttributeChip(
          icon: FontAwesomeIcons.dumbbell,
          label: 'Strength: ${player.attributes.strength}',
          color: Colors.red,
        ),
        _buildAttributeChip(
          icon: FontAwesomeIcons.brain,
          label: 'IQ: ${player.attributes.iq}',
          color: Colors.green,
        ),
        _buildAttributeChip(
          icon: FontAwesomeIcons.handshake,
          label: 'Teamwork: ${player.attributes.teamwork}',
          color: Colors.purple,
        ),
        if (player.attributes.specialSkill != null)
          _buildAttributeChip(
            icon: FontAwesomeIcons.star,
            label: player.attributes.specialSkill!,
            color: Colors.amber,
          ),
      ],
    );
  }

  Widget _buildAttributeChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      avatar: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCertificates(List<String> certificates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certificates:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: certificates.map((cert) {
            return Chip(
              backgroundColor: Colors.grey[100],
              label: Text(
                cert,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Players'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildFilterSection(
                  title: 'Sport',
                  options: const ['Football', 'Basketball', 'Tennis', 'Cricket', 'Volleyball'],
                ),
                _buildFilterSection(
                  title: 'Position',
                  options: const ['Forward', 'Midfielder', 'Defender', 'Goalkeeper', 'Point Guard', 'Center'],
                ),
                _buildFilterSection(
                  title: 'Rating',
                  options: const ['4+', '3+', '2+', '1+'],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection({required String title, required List<String> options}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {
                // Handle filter selection
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Player model and sample data are imported from player_model.dart