const express = require('express');
const router = express.Router();
const { createDrop, getLatestDrop, createTestData } = require('../controllers/dropsController');

router.post('/', createDrop);
router.get('/latest/:userId', getLatestDrop);
router.post('/test-data', createTestData);

module.exports = router; 