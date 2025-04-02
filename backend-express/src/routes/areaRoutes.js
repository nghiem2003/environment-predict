const express = require('express');
const { authenticate } = require('../middlewares/authMiddleware');
const { getAllAreas, getAreaById } = require('../controllers/areaController');
const router = express.Router();

router.get('/', getAllAreas);
router.get('/:id', getAreaById);
module.exports = router;
