const express = require('express');
const router = express.Router();
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Import models (assuming we'll create a DrillResult model)
const DrillResult = require('../models/DrillResult');

// Save a drill result
router.post('/drill-results', async (req, res) => {
  try {
    const { userId, sport, drill, grade, feedback, date } = req.body;
    
    // Validate required fields
    if (!userId || !sport || !drill || !grade || !feedback) {
      return res.status(400).json({ message: 'Missing required fields' });
    }
    
    // Create new drill result
    const newDrillResult = new DrillResult({
      userId,
      sport,
      drill,
      grade,
      feedback,
      date: date || new Date().toISOString()
    });
    
    // Save to database
    const savedResult = await newDrillResult.save();
    
    res.status(201).json(savedResult);
  } catch (error) {
    console.error('Error saving drill result:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get drill results for a user
router.get('/drill-results/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Find all drill results for this user
    const results = await DrillResult.find({ userId }).sort({ date: -1 });
    
    res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching drill results:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Endpoint to run Python script for drill analysis
router.post('/analyze-drill', (req, res) => {
  try {
    const { drill, video_path } = req.body;
    
    if (!drill) {
      return res.status(400).json({ message: 'Drill name is required' });
    }
    
    // Path to Python script
    const scriptPath = path.join(__dirname, '../../python_scripts/drill_analyzer.py');
    
    // Check if script exists
    if (!fs.existsSync(scriptPath)) {
      return res.status(500).json({ message: 'Analysis script not found' });
    }
    
    // Prepare input data
    const inputData = JSON.stringify({
      drill,
      video_path: video_path || null
    });
    
    // Spawn Python process
    const pythonProcess = spawn('python', [scriptPath]);
    
    // Send input data to script
    pythonProcess.stdin.write(inputData);
    pythonProcess.stdin.end();
    
    let result = '';
    let error = '';
    
    // Collect output
    pythonProcess.stdout.on('data', (data) => {
      result += data.toString();
    });
    
    // Collect errors
    pythonProcess.stderr.on('data', (data) => {
      error += data.toString();
    });
    
    // Handle process completion
    pythonProcess.on('close', (code) => {
      if (code !== 0) {
        console.error(`Python script exited with code ${code}`);
        console.error(`Error: ${error}`);
        return res.status(500).json({ message: 'Analysis failed', error });
      }
      
      try {
        // Parse the JSON result
        const analysisResult = JSON.parse(result);
        res.status(200).json(analysisResult);
      } catch (e) {
        console.error('Error parsing Python script output:', e);
        res.status(500).json({ message: 'Error parsing analysis result', error: e.message });
      }
    });
  } catch (error) {
    console.error('Error running drill analysis:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;