const mongoose = require("mongoose");

const mealLogSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  mealTitle: String,
  calories: Number,
  protein: String,
  carbs: String,
  fat: String,
  mealType: { type: String, enum: ["Breakfast", "Lunch", "Dinner", "Snack"] },
  loggedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("MealLog", mealLogSchema);
