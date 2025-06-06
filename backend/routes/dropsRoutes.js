const express = require('express');
const router = express.Router();
const { createDrop, getLatestDrop } = require('../controllers/dropsController');

router.post('/', createDrop);
router.get('/latest/:userId', getLatestDrop);

module.exports = router; 