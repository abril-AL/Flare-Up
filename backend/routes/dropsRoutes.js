const express = require('express');
const router = express.Router();
const { createDrop, getLatestDrop, createDropForWeek } = require('../controllers/dropsController');

router.post('/', createDrop);
router.get('/latest/:userId', getLatestDrop);
router.post('/week', createDropForWeek);

module.exports = router; 