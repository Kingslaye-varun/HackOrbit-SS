const mongoose = require("mongoose");

const tournamentSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  date: { type: Date, required: true },
  userId: { type: String, required: true }, // Reference to the user's uid
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Tournament", tournamentSchema);