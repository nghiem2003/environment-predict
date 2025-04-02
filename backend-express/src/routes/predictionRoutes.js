const express = require('express');
const {
  createPrediction,
  getLatestPrediction,
  getPredictionDetails,
  getPredictionsByUser,
  getAllPredictionsWithFilters,
} = require('../controllers/predictionController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

router.post('/batch',authenticate,authorize['expert'])

router.post(
  '/',
  //authenticate,
  //authorize(['expert', 'admin']),
  createPrediction
);
router.get('/:areaId/latest', getLatestPrediction);
router.get(
  '/:predictionId',
  authenticate,
  authorize(['expert', 'admin']),
  getPredictionDetails
);
router.get(
  '/admin',
  authenticate,
  authorize(['admin']),
  getAllPredictionsWithFilters
);

router.get(
  '/user/:userId',
  authenticate,
  authorize(['expert']),
  getPredictionsByUser
);

module.exports = router;
