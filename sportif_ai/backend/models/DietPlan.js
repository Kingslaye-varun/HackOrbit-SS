const mongoose = require("mongoose");

const dietPlanSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  gender: String,
  age: Number,
  weight: Number,
  height: Number,
  goal: String,
  sport: String,
  activityLevel: Number,
  calories: Number,
  protein: Number,
  carbs: Number,
  fats: Number,
}, { timestamps: true });

module.exports = mongoose.model("DietPlan", dietPlanSchema);
