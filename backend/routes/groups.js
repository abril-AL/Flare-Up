const express = require('express');
const router = express.Router();
const {
  createGroup,
  sendGroupInvite,
  acceptGroupInvite,
  declineGroupInvite,
  getUserGroups,
  getGroupMembers,
  getUserGroupDetails
} = require('../controllers/groupsController');

router.post('/', createGroup); // Create group (optionally with invites)
router.post('/invite', sendGroupInvite); // Invite user to group
router.post('/invite/accept', acceptGroupInvite); // Accept invite
router.post('/invite/decline', declineGroupInvite); // Decline invite
router.get('/user/:user_id', getUserGroups); // Get groups for user
router.get('/:group_id/members', getGroupMembers); // Get users in a group
router.get('/user/:user_id/details', getUserGroupDetails);

module.exports = router;
