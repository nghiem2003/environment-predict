const express = require('express');
const {
  createPrediction,
  getLatestPrediction,
  getPredictionDetails,
  getPredictionsByUser,
  getAllPredictionsWithFilters,
  createBatchPrediction,
} = require('../controllers/predictionController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

router.post(
  '/batch',
  authenticate,
  authorize(['expert']),
  createBatchPrediction
);

router.post(
  '/',
  //authenticate,
  //authorize(['expert', 'admin']),
  createPrediction
);
router.get(
  '/admin',
  authenticate,
  authorize(['admin', 'manager']),
  getAllPredictionsWithFilters
);
router.get('/:areaId/latest', getLatestPrediction);

router.get(
  '/:predictionId',
  authenticate,
  authorize(['expert', 'admin', 'manager']),
  getPredictionDetails
);

router.get(
  '/user/:userId',
  authenticate,
  authorize(['expert']),
  getPredictionsByUser
);

module.exports = router;
