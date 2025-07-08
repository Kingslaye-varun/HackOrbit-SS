const express = require("express");
const router = express.Router();
const Tournament = require("../models/Tournament");

// Create a new tournament
router.post("/", async (req, res) => {
  try {
    console.log('Received tournament creation request:', req.body);
    const { name, description, date, userId } = req.body;
    
    if (!name || !description || !date || !userId) {
      console.error('Missing required fields');
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const tournament = new Tournament({
      name,
      description,
      date,
      userId
    });
    
    await tournament.save();
    console.log('Tournament created successfully:', tournament);
    return res.status(201).json(tournament);
  } catch (err) {
    console.error('Error creating tournament:', err);
    res.status(500).json({ 
      error: err.message,
      stack: process.env.NODE_ENV === 'production' ? null : err.stack 
    });
  }
});

// Get all tournaments for a specific user
router.get("/user/:userId", async (req, res) => {
  try {
    const tournaments = await Tournament.find({ userId: req.params.userId }).sort({ date: 1 });
    res.json(tournaments);
  } catch (err) {
    console.error('Error fetching tournaments:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get a specific tournament
router.get("/:id", async (req, res) => {
  try {
    const tournament = await Tournament.findById(req.params.id);
    if (!tournament) {
      return res.status(404).json({ message: "Tournament not found" });
    }
    res.json(tournament);
  } catch (err) {
    console.error('Error fetching tournament:', err);
    res.status(500).json({ error: err.message });
  }
});

// Update a tournament
router.put("/:id", async (req, res) => {
  try {
    const tournament = await Tournament.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!tournament) {
      return res.status(404).json({ message: "Tournament not found" });
    }
    console.log('Tournament updated successfully:', tournament);
    res.json(tournament);
  } catch (err) {
    console.error('Error updating tournament:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete a tournament
router.delete("/:id", async (req, res) => {
  try {
    const tournament = await Tournament.findByIdAndDelete(req.params.id);
    if (!tournament) {
      return res.status(404).json({ message: "Tournament not found" });
    }
    console.log('Tournament deleted successfully:', tournament);
    res.json({ message: "Tournament deleted successfully" });
  } catch (err) {
    console.error('Error deleting tournament:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;