const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  email: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  photoUrl: { type: String },
  sport: { type: String },
  // AI Dietician related fields
  gender: { type: String, enum: ['Male', 'Female', 'Other'] },
  age: { type: Number },
  height: { type: Number }, // in cm
  weight: { type: Number }, // in kg
  dietaryPreference: { type: String, enum: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Pescatarian', 'Other'] },
  fitnessGoal: { type: String, enum: ['Gain Muscle', 'Cut Fat', 'Maintain Weight', 'Improve Performance', 'Other'] },
  activityLevel: { type: Number, min: 1.2, max: 2.0, default: 1.2 }, // 1.2 (sedentary) to 2.0 (very active)
  hydrationReminder: { type: Boolean, default: false },
  mealReminder: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("User", userSchema);