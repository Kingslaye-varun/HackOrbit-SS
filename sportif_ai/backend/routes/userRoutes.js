const express = require("express");
const router = express.Router();
const User = require("../models/User");

// Create or update user
router.post("/", async (req, res) => {
  try {
    console.log('Received user creation/update request:', req.body);
    const { uid } = req.body;
    
    if (!uid) {
      console.error('Missing required field: uid');
      return res.status(400).json({ error: 'Missing required field: uid' });
    }
    
    // Check if user exists
    let user = await User.findOne({ uid });
    
    if (user) {
      console.log(`User with uid ${uid} already exists, updating...`);
      // Update existing user
      user = await User.findOneAndUpdate(
        { uid },
        req.body,
        { new: true }
      );
      console.log('User updated successfully:', user);
      return res.status(200).json(user); // Return 200 for updates
    } else {
      console.log(`Creating new user with uid ${uid}...`);
      // Create new user
      user = new User(req.body);
      await user.save();
      console.log('User created successfully:', user);
      return res.status(201).json(user); // Return 201 for creation
    }
  } catch (err) {
    console.error('Error creating/updating user:', err);
    res.status(500).json({ 
      error: err.message,
      stack: process.env.NODE_ENV === 'production' ? null : err.stack 
    });
  }
});

// Get all users
router.get("/", async (req, res) => {
  try {
    console.log('Fetching all users');
    const users = await User.find({});
    console.log(`Found ${users.length} users`);
    res.json(users);
  } catch (err) {
    console.error('Error fetching all users:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get user by uid
router.get("/:uid", async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.params.uid });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update user
router.put("/:uid", async (req, res) => {
  try {
    const user = await User.findOneAndUpdate(
      { uid: req.params.uid },
      req.body,
      { new: true }
    );
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;