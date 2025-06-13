const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

app.use(cors());
app.use(express.json({ limit: '20mb' }));

// Add this here
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.originalUrl}`);
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    console.log('Body:', req.body);
  }
  next();
});

// Load routes
app.use('/users', require('./routes/users'));
app.use('/auth', require('./routes/authRoutes'));
app.use('/friends', require('./routes/friends'));
app.use('/flares', require('./routes/flares'));
const screentimeRoutes = require('./routes/screentimeRoutes');
const dropsRoutes = require('./routes/dropsRoutes');
// app.use("/drops", require("./routes/drops"));

//app.use('/groups', require('./routes/groups'));

app.use('/screentime', screentimeRoutes);
app.use('/drops', dropsRoutes);



const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});


