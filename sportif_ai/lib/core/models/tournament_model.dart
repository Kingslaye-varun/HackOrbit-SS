import 'package:intl/intl.dart';

class Tournament {
  final String? id;
  final String name;
  final String description;
  final DateTime date;
  final String userId;
  final DateTime? createdAt;

  Tournament({
    this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.userId,
    this.createdAt,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy – hh:mm a').format(date);
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? date,
    String? userId,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}