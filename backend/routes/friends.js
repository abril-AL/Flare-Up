const express = require('express');
const router = express.Router();
const {
  sendFriendRequest,
  acceptFriendRequest,
  removeFriend,
  declineFriendRequest,
  getFriends,
  getFriendRequests,
  getRankedFriends,
} = require('../controllers/friendsController');

router.post('/request', sendFriendRequest);
router.post('/accept', acceptFriendRequest);
router.post('/decline', declineFriendRequest);
router.delete('/', removeFriend);
router.get('/requests/:user_id', getFriendRequests);
router.get('/:user_id', getFriends);
router.get('/ranked/:userId', getRankedFriends);


module.exports = router;
