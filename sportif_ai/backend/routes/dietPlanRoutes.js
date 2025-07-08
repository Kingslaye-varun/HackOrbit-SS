const express = require("express");
const router = express.Router();
const DietPlan = require("../models/DietPlan");

// POST /api/diet-plan
router.post("/", async (req, res) => {
  try {
    const newPlan = new DietPlan(req.body);
    await newPlan.save();
    res.status(201).json(newPlan);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/diet-plan/:userId
router.get("/:userId", async (req, res) => {
  try {
    const plans = await DietPlan.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    res.json(plans);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
