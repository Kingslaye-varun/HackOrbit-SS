class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final String? sport;
  // AI Dietician related fields
  final String? gender;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? dietaryPreference;
  final String? fitnessGoal;
  final double? activityLevel; // 1.2 (sedentary) to 2.0 (very active)
  final bool hydrationReminder;
  final bool mealReminder;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.sport,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.dietaryPreference,
    this.fitnessGoal,
    this.activityLevel,
    this.hydrationReminder = false,
    this.mealReminder = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      photoUrl: json['photoUrl'],
      sport: json['sport'],
      gender: json['gender'],
      age: json['age'] != null ? int.parse(json['age'].toString()) : null,
      height: json['height'] != null ? double.parse(json['height'].toString()) : null,
      weight: json['weight'] != null ? double.parse(json['weight'].toString()) : null,
      dietaryPreference: json['dietaryPreference'],
      fitnessGoal: json['fitnessGoal'],
      activityLevel: json['activityLevel'] != null ? double.parse(json['activityLevel'].toString()) : null,
      hydrationReminder: json['hydrationReminder'] ?? false,
      mealReminder: json['mealReminder'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'sport': sport,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'dietaryPreference': dietaryPreference,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'hydrationReminder': hydrationReminder,
      'mealReminder': mealReminder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? sport,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? dietaryPreference,
    String? fitnessGoal,
    double? activityLevel,
    bool? hydrationReminder,
    bool? mealReminder,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      sport: sport ?? this.sport,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      hydrationReminder: hydrationReminder ?? this.hydrationReminder,
      mealReminder: mealReminder ?? this.mealReminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
