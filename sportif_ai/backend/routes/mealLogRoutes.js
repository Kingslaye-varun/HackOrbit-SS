const express = require("express");
const router = express.Router();
const MealLog = require("../models/MealLog");

// POST /api/meal-log
router.post("/", async (req, res) => {
  try {
    const log = new MealLog(req.body);
    await log.save();
    res.status(201).json(log);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/meal-log/:userId
router.get("/:userId", async (req, res) => {
  try {
    const logs = await MealLog.find({ userId: req.params.userId }).sort({ loggedAt: -1 });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
