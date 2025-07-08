const mongoose = require('mongoose');

const drillResultSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  sport: {
    type: String,
    required: true
  },
  drill: {
    type: String,
    required: true
  },
  grade: {
    type: String,
    required: true,
    enum: ['Excellent', 'Good', 'Needs Improvement']
  },
  feedback: {
    type: [String],
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('DrillResult', drillResultSchema);