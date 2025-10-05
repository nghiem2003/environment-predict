const express = require('express');
const {
  createPrediction,
  getLatestPrediction,
  getPredictionHistory,
  getPredictionDetails,
  getPredictionsByUser,
  getAllPredictionsWithFilters,
  createBatchPrediction,
  getPredictionChartData,
  getAllPredictionChartData,
  createBatchPredictionFromExcel
} = require('../controllers/predictionController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

const router = express.Router();

router.post(
  '/batch',
  authenticate,
  authorize(['expert', 'manager']),
  createBatchPrediction
);

// Upload Excel for batch predictions
router.post(
  '/excel',
  authenticate,
  authorize(['expert', 'manager']),
  upload.single('file'),
  createBatchPredictionFromExcel
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
router.get('/:areaId/history', getPredictionHistory);

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

// Get prediction data for charts
router.get(
  '/chart/data',
  getPredictionChartData
);

// Get all prediction data for charts (all areas)
router.get(
  '/chart/all',
  getAllPredictionChartData
);

module.exports = router;
