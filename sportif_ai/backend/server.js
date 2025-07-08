const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();

// Configure CORS to accept requests from any origin
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Increase JSON payload size limit
app.use(express.json({ limit: '10mb' }));

// MongoDB connection with proper error handling
const connectDB = async () => {
  try {
    if (!process.env.MONGO_URL) {
      console.error("❌ MONGO_URL is not defined in environment variables");
      process.exit(1);
    }

    console.log("🔄 Connecting to MongoDB...");
    
    const conn = await mongoose.connect(process.env.MONGO_URL, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database Name: ${conn.connection.name}`);
  } catch (error) {
    console.error("❌ MongoDB connection error:", error.message);
    process.exit(1);
  }
};

// MongoDB connection event listeners
mongoose.connection.on('connected', () => {
  console.log('🟢 Mongoose connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
  console.error('🔴 Mongoose connection error:', err);
});

mongoose.connection.on('disconnected', () => {
  console.log('🟡 Mongoose disconnected from MongoDB');
});

// Connect to database
connectDB();

// Routes
console.log("📁 Loading routes...");

try {
  console.log("🔍 Loading dietPlanRoutes...");
  app.use("/api/diet-plan", require("./routes/dietPlanRoutes"));
  console.log("✅ dietPlanRoutes loaded successfully");
} catch (error) {
  console.error("❌ Error loading dietPlanRoutes:", error.message);
}

try {
  console.log("🔍 Loading mealLogRoutes...");
  app.use("/api/meal-log", require("./routes/mealLogRoutes"));
  console.log("✅ mealLogRoutes loaded successfully");
} catch (error) {
  console.error("❌ Error loading mealLogRoutes:", error.message);
}

try {
  console.log("🔍 Loading userRoutes...");
  app.use("/api/users", require("./routes/userRoutes"));
  console.log("✅ userRoutes loaded successfully");
} catch (error) {
  console.error("❌ Error loading userRoutes:", error.message);
}

try {
  console.log("🔍 Loading drillResultRoutes...");
  app.use("/api", require("./routes/drillResultRoutes"));
  console.log("✅ drillResultRoutes loaded successfully");
} catch (error) {
  console.error("❌ Error loading drillResultRoutes:", error.message);
}

try {
  console.log("🔍 Loading tournamentRoutes...");
  app.use("/api/tournaments", require("./routes/tournamentRoutes"));
  console.log("✅ tournamentRoutes loaded successfully");
} catch (error) {
  console.error("❌ Error loading tournamentRoutes:", error.message);
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    mongodb: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected',
    timestamp: new Date().toISOString()
  });
});

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server Error:', err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Simple 404 handler (removed the problematic app.use('*', ...))
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌐 Health check available at: http://localhost:${PORT}/health`);
  console.log(`🏠 Root endpoint: http://localhost:${PORT}/`);
});