const express = require('express');
const router = express.Router();
const { createFlare, getOutgoingFlares, getIncomingFlares, deleteFlare } = require('../controllers/flaresController');

router.post('/', createFlare);
router.get('/outgoing/:sender_id', getOutgoingFlares);
router.get('/incoming/:recipient_id', getIncomingFlares);
router.delete('/:id', deleteFlare);



module.exports = router;
