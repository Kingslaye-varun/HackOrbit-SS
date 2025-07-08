import 'package:flutter/material.dart';

// Player model
class Player {
  final String name;
  final String sport;
  final String position;
  final String? role;
  final double overallRating;
  final PlayerAttributes attributes;
  final List<String> certificates;
  final String? imageUrl;

  Player({
    required this.name,
    required this.sport,
    required this.position,
    this.role,
    required this.overallRating,
    required this.attributes,
    required this.certificates,
    this.imageUrl,
  });
}

class PlayerAttributes {
  final int speed;
  final int strength;
  final int iq;
  final int teamwork;
  final String? specialSkill;

  PlayerAttributes({
    required this.speed,
    required this.strength,
    required this.iq,
    required this.teamwork,
    this.specialSkill,
  });
}

// Sample data
final List<Player> players = [
  Player(
    name: 'Alex Johnson',
    sport: 'Football',
    position: 'Forward',
    role: 'Striker',
    overallRating: 4.5,
    imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    attributes: PlayerAttributes(
      speed: 90,
      strength: 85,
      iq: 80,
      teamwork: 75,
      specialSkill: 'Precision Shooting',
    ),
    certificates: [
      'FIFA Youth Certificate',
      'Regional MVP 2024',
    ],
  ),
  Player(
    name: 'Sarah Williams',
    sport: 'Basketball',
    position: 'Point Guard',
    role: 'Playmaker',
    overallRating: 4.2,
    imageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
    attributes: PlayerAttributes(
      speed: 85,
      strength: 70,
      iq: 95,
      teamwork: 90,
      specialSkill: '3-Point Specialist',
    ),
    certificates: [
      'National Basketball Academy',
      'State Championship 2023',
    ],
  ),
  Player(
    name: 'Michael Brown',
    sport: 'Football',
    position: 'Midfielder',
    role: 'Playmaker',
    overallRating: 4.0,
    imageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
    attributes: PlayerAttributes(
      speed: 80,
      strength: 75,
      iq: 90,
      teamwork: 85,
      specialSkill: 'Long Pass Accuracy',
    ),
    certificates: [
      'Elite Youth Program',
      'Best Midfielder Award',
    ],
  ),
  Player(
    name: 'Emma Davis',
    sport: 'Tennis',
    position: 'Singles',
    role: 'Baseline Player',
    overallRating: 4.7,
    imageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    attributes: PlayerAttributes(
      speed: 95,
      strength: 80,
      iq: 85,
      teamwork: 60,
      specialSkill: 'Power Serve',
    ),
    certificates: [
      'ITF Junior Champion',
      'National Tennis Academy',
    ],
  ),
  Player(
    name: 'James Wilson',
    sport: 'Basketball',
    position: 'Center',
    role: 'Defensive Anchor',
    overallRating: 3.8,
    imageUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    attributes: PlayerAttributes(
      speed: 65,
      strength: 95,
      iq: 80,
      teamwork: 85,
      specialSkill: 'Shot Blocking',
    ),
    certificates: [
      'Regional All-Star',
    ],
  ),
];