class DrillResult {
  final String userId;
  final String sport;
  final String drill;
  final String grade;
  final List<String> feedback;
  final String date;

  DrillResult({
    required this.userId,
    required this.sport,
    required this.drill,
    required this.grade,
    required this.feedback,
    required this.date,
  });

  factory DrillResult.fromJson(Map<String, dynamic> json) {
    return DrillResult(
      userId: json['userId'],
      sport: json['sport'],
      drill: json['drill'],
      grade: json['grade'],
      feedback: List<String>.from(json['feedback']),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sport': sport,
      'drill': drill,
      'grade': grade,
      'feedback': feedback,
      'date': date,
    };
  }
}