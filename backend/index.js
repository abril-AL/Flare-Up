const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.originalUrl}`);
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    console.log('Body:', req.body);
  }
  next();
});

// Load routes
app.use('/auth', require('./routes/authRoutes'));
app.use('/friends', require('./routes/friends'));
const screentimeRoutes = require('./routes/screentimeRoutes');
const dropsRoutes = require('./routes/dropsRoutes');

app.use('/screentime', screentimeRoutes);
app.use('/drops', dropsRoutes);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});


