const express = require('express');
const router = express.Router();
const {
  addScreentime,
  getScreentime,
  getLatestDrop
} = require('../controllers/screentimeController');

router.get('/test', (req, res) => {
  res.json({ message: "screentime route works!" });
});

router.post('/', addScreentime);
router.get('/:userId', getScreentime);
router.get('/latest/:userId', getLatestDrop); 

module.exports = router;
