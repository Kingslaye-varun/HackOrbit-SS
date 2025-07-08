class DietInput {
  final String gender;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String goal; // "Gain Muscle", "Cut Fat", etc.
  final String sport; // "Tennis", "Weightlifting"
  final double activityLevel; // 1.2 to 2.0

  DietInput({
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.sport,
    required this.activityLevel,
  });
}

class MealPlan {
  final int calories;
  final double protein; // grams
  final double carbs;
  final double fats;

  MealPlan({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

class DietPlanUseCase {
  MealPlan generate(DietInput input) {
    double bmr = (input.gender.toLowerCase() == "male")
        ? 10 * input.weight + 6.25 * input.height - 5 * input.age + 5
        : 10 * input.weight + 6.25 * input.height - 5 * input.age - 161;

    double tdee = bmr * input.activityLevel;

    int targetCalories = tdee.round();

    // Macronutrient split
    double protein = input.weight * (input.goal == "Gain Muscle" ? 2.0 : 1.5); // g/kg
    double proteinCalories = protein * 4;

    double fatPercentage = 0.25;
    double fat = (targetCalories * fatPercentage) / 9;

    double remainingCalories = targetCalories - proteinCalories - (fat * 9);
    double carbs = remainingCalories / 4;

    return MealPlan(
      calories: targetCalories,
      protein: double.parse(protein.toStringAsFixed(1)),
      carbs: double.parse(carbs.toStringAsFixed(1)),
      fats: double.parse(fat.toStringAsFixed(1)),
    );
  }
}
