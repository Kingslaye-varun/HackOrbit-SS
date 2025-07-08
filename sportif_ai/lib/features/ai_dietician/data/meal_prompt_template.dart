import '../../../core/models/user_model.dart';
import '../domain/diet_plan_usecase.dart';

class MealPromptTemplate {
  static String getPromptForMealSuggestions({
    required UserModel user,
    required MealPlan mealPlan,
  }) {

    // Build a detailed prompt for the Gemini API
    return """
    You are a specialized sports nutritionist for athletes from India and Asia.
    
    Generate 5 meal suggestions that are:
    1. Affordable and easily available in India/Asia
    2. Culturally appropriate for the region
    3. Nutritious and aligned with athletic performance
    4. Non-static, varied, and interesting
    5. Specific with real food items (not generic descriptions)
    
    Athlete Profile:
    - Name: ${user.name ?? 'Athlete'}
    - Sport: ${user.sport ?? 'General sports'}
    - Age: ${user.age ?? 'Adult'}
    - Gender: ${user.gender ?? 'Not specified'}
    - Weight: ${user.weight ?? '70'} kg
    - Height: ${user.height ?? '170'} cm
    - Fitness Goal: ${user.fitnessGoal ?? 'Performance'}
    - Dietary Preference: ${user.dietaryPreference ?? 'Non-Vegetarian'}
    
    Nutritional Requirements (daily):
    - Calories: ${mealPlan.calories.toInt()} kcal
    - Protein: ${mealPlan.protein.toInt()} g
    - Carbs: ${mealPlan.carbs.toInt()} g
    - Fats: ${mealPlan.fats.toInt()} g
    
    Important Guidelines:
    - Focus on locally available, affordable ingredients common in Indian/Asian markets
    - Include traditional dishes with nutritional benefits for athletes
    - Suggest meals that are easy to prepare
    - Include specific ingredient amounts and preparation methods
    - Consider seasonal availability of ingredients
    - Provide options that balance cost with nutritional value
    - The user is ${user.dietaryPreference?.toLowerCase() ?? 'non-vegetarian'}, so ONLY suggest ${user.dietaryPreference?.toLowerCase() ?? 'non-vegetarian'} meals
    
    Return ONLY a JSON array of meal objects with the following structure:
    [
      {
        "title": "Meal name",
        "description": "Brief description with ingredients and preparation",
        "calories": calories_number,
        "protein": protein_grams,
        "carbs": carbs_grams,
        "fat": fat_grams,
        "cost": "Low/Medium/High",
        "preparation_time": "time in minutes",
        "region": "Specific region in India/Asia this meal is from"
      },
      ...
    ]
    
    Do not include any explanations or text outside of the JSON structure.
    """;
  }
}