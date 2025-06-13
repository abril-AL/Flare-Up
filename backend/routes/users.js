const express = require('express');
const router = express.Router();
const { signup, getUserIdByUsername } = require('../controllers/usersController');

router.post('/signup', signup);
router.get('/lookup/:username', getUserIdByUsername);


module.exports = router;
