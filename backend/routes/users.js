const express = require('express');
const router = express.Router();
const { getUser, updateUser } = require('../controllers/usersController');

const express = require('express');
const { initializeUserProfile } = require('../controllers/usersController');
const { authenticate } = require('../middleware/auth');

router.get('/profile', getUser);
router.put('/profile', updateUser);

router.post('/init', authenticate, initializeUserProfile);

module.exports = router;
