class MealPromptTemplate {
  static String getPromptForMealSuggestions({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String dietaryPreference,
    required String fitnessGoal,
    required String sport,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) {
    final String dietaryRestriction = dietaryPreference == 'Vegetarian' ? 'vegetarian' : 'non-vegetarian';
    
    return """
    You are a specialized sports nutritionist for athletes from India and Asia.
    
    Generate 5 meal suggestions that are:
    1. Affordable and easily available in India/Asia
    2. Culturally appropriate for the region
    3. Nutritious and aligned with athletic performance
    4. Non-static, varied, and interesting
    5. Specific with real food items (not generic descriptions)
    
    Athlete Profile:
    - Gender: $gender
    - Age: $age years
    - Height: $height cm
    - Weight: $weight kg
    - Dietary Preference: $dietaryPreference
    - Fitness Goal: $fitnessGoal
    - Sport: $sport
    
    Nutritional Requirements (daily):
    - Calories: $calories kcal
    - Protein: $protein g
    - Carbs: $carbs g
    - Fats: $fats g
    
    IMPORTANT GUIDELINES:
    1. The user is $dietaryRestriction, so ONLY suggest $dietaryRestriction meals.
    2. Focus on affordable, easily available ingredients common in Indian/Asian markets
    3. Include traditional dishes with nutritional benefits for athletes
    4. Suggest meals that are easy to prepare
    5. Include specific ingredient amounts and preparation methods
    6. Consider seasonal availability of ingredients
    7. Provide options that balance cost with nutritional value
    8. Include regional dishes from different parts of India and Asia
    9. Suggest meals that can be prepared with minimal equipment and time
    10. Include local superfoods and protein sources common in Indian/Asian diets
    11. DO NOT suggest generic Western meals - focus specifically on Indian and Asian cuisine
    12. Consider regional availability of ingredients across different parts of India and Asia
    
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