import 'package:flutter/material.dart';
import 'package:sportif_ai/routes/app_routes.dart';
import 'package:sportif_ai/features/Scout_players/player_model.dart';
import 'package:sportif_ai/features/Scout_players/player_service.dart';
import 'package:sportif_ai/features/Scout_players/widgets/player_card.dart';

class ScoutPlayersScreen extends StatefulWidget {
  const ScoutPlayersScreen({super.key});

  @override
  State<ScoutPlayersScreen> createState() => _ScoutPlayersScreenState();
}

class _ScoutPlayersScreenState extends State<ScoutPlayersScreen> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  List<Player> _filteredPlayers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSport;
  String? _selectedPosition;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final players = await _playerService.fetchPlayers();
      setState(() {
        _players = players;
        _filteredPlayers = players;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _players = players; // Fallback to sample data
        _filteredPlayers = players;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading players: $e')),
      );
    }
  }

  void _filterPlayers() {
    setState(() {
      _filteredPlayers = _players.where((player) {
        // Filter by search query
        if (_searchQuery.isNotEmpty &&
            !player.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }

        // Filter by sport
        if (_selectedSport != null && player.sport != _selectedSport) {
          return false;
        }

        // Filter by position
        if (_selectedPosition != null && player.position != _selectedPosition) {
          return false;
        }

        // Filter by rating
        if (_minRating != null && player.overallRating < _minRating!) {
          return false;
        }

        return true;
      }).toList();
    });
  }

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPlayers.isEmpty
                      ? const Center(child: Text('No players found'))
                      : ListView.builder(
                          itemCount: _filteredPlayers.length,
                          itemBuilder: (context, index) {
                            return PlayerCard(
                              player: _filteredPlayers[index],
                              onTap: () => AppRoutes.navigateToPlayerDetails(
                                  context, _filteredPlayers[index]),
                            );
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
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                  _filterPlayers();
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        _filterPlayers();
      },
    );
  }

  // Helper methods for the filter dialog are below

  void _showFilterDialog(BuildContext context) {
    // Create temporary variables to hold filter state during dialog
    String? tempSelectedSport = _selectedSport;
    String? tempSelectedPosition = _selectedPosition;
    double? tempMinRating = _minRating;

    // Get unique sports and positions from available players
    final sports = _players.map((p) => p.sport).toSet().toList();
    final positions = _players.map((p) => p.position).toSet().toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Players'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildFilterSection(
                      title: 'Sport',
                      options: sports,
                      selectedValue: tempSelectedSport,
                      onSelected: (value) {
                        setDialogState(() {
                          tempSelectedSport = tempSelectedSport == value ? null : value;
                        });
                      },
                    ),
                    _buildFilterSection(
                      title: 'Position',
                      options: positions,
                      selectedValue: tempSelectedPosition,
                      onSelected: (value) {
                        setDialogState(() {
                          tempSelectedPosition = tempSelectedPosition == value ? null : value;
                        });
                      },
                    ),
                    _buildRatingFilter(
                      selectedRating: tempMinRating,
                      onSelected: (value) {
                        setDialogState(() {
                          tempMinRating = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSport = null;
                      _selectedPosition = null;
                      _minRating = null;
                    });
                    _filterPlayers();
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedSport = tempSelectedSport;
                      _selectedPosition = tempSelectedPosition;
                      _minRating = tempMinRating;
                    });
                    _filterPlayers();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
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
              selected: selectedValue == option,
              onSelected: (selected) {
                onSelected(option);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRatingFilter({
    required double? selectedRating,
    required Function(double?) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [4.5, 4.0, 3.5, 3.0].map((rating) {
            return FilterChip(
              label: Text('$rating+'),
              selected: selectedRating == rating,
              onSelected: (selected) {
                onSelected(selected ? rating : null);
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