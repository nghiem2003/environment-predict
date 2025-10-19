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

/**
 * @swagger
 * /predictions/batch:
 *   post:
 *     summary: Create batch predictions
 *     tags: [Predictions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - predictions
 *             properties:
 *               predictions:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required:
 *                     - area_id
 *                     - prediction_data
 *                   properties:
 *                     area_id:
 *                       type: integer
 *                       example: 1
 *                     prediction_data:
 *                       type: object
 *                       example: {"temperature": 25, "salinity": 30, "ph": 7.5}
 *     responses:
 *       201:
 *         description: Batch predictions created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Success'
 *       400:
 *         description: Bad request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 */
router.post(
  '/batch',
  authenticate,
  authorize(['expert', 'manager']),
  createBatchPrediction
);

/**
 * @swagger
 * /predictions/excel:
 *   post:
 *     summary: Upload Excel file for batch predictions
 *     tags: [Predictions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - file
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *                 description: Excel file containing prediction data
 *     responses:
 *       201:
 *         description: Excel file processed and predictions created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Excel file processed successfully"
 *                 predictions_created:
 *                   type: integer
 *                   example: 10
 *       400:
 *         description: Bad request or invalid file format
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 */
router.post(
  '/excel',
  authenticate,
  authorize(['expert', 'manager']),
  upload.single('file'),
  createBatchPredictionFromExcel
);

/**
 * @swagger
 * /predictions:
 *   post:
 *     summary: Create single prediction
 *     tags: [Predictions]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - area_id
 *               - prediction_data
 *             properties:
 *               area_id:
 *                 type: integer
 *                 example: 1
 *               prediction_data:
 *                 type: object
 *                 example: {"temperature": 25, "salinity": 30, "ph": 7.5}
 *               user_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Prediction created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Success'
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.post(
  '/',
  //authenticate,
  //authorize(['expert', 'admin']),
  createPrediction
);

/**
 * @swagger
 * /predictions/admin:
 *   get:
 *     summary: Get all predictions with filters (Admin/Manager only)
 *     tags: [Predictions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Number of predictions per page
 *       - in: query
 *         name: area_id
 *         schema:
 *           type: integer
 *         description: Filter by area ID
 *       - in: query
 *         name: user_id
 *         schema:
 *           type: integer
 *         description: Filter by user ID
 *       - in: query
 *         name: start_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter by start date
 *       - in: query
 *         name: end_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Filter by end date
     *     responses:
     *       200:
     *         description: List of predictions with filters
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 rows:
     *                   type: array
     *                   description: Array of prediction objects
     *                   items:
     *                     type: object
     *                     properties:
     *                       id:
     *                         type: integer
     *                         description: Prediction ID
     *                         example: 1
     *                       user_id:
     *                         type: integer
     *                         description: User ID who made the prediction
     *                         example: 1
     *                       area_id:
     *                         type: integer
     *                         description: Area ID for the prediction
     *                         example: 1
     *                       prediction_text:
     *                         type: string
     *                         description: Prediction result text
     *                         example: "Good conditions for aquaculture"
     *                       createdAt:
     *                         type: string
     *                         format: date-time
     *                         description: Creation timestamp
     *                         example: "2024-01-01T00:00:00Z"
     *                       updatedAt:
     *                         type: string
     *                         format: date-time
     *                         description: Last update timestamp
     *                         example: "2024-01-01T00:00:00Z"
     *                       Area:
     *                         type: object
     *                         description: Associated area information
     *                         properties:
     *                           id:
     *                             type: integer
     *                             example: 1
     *                           name:
     *                             type: string
     *                             example: "Khu vực nuôi hàu A"
     *                 count:
     *                   type: integer
     *                   description: Total number of predictions
     *                   example: 15
     *             examples:
     *               success:
     *                 summary: Successful response
     *                 value:
     *                   rows:
     *                     - id: 1
     *                       area_id: 1
     *                       user_id: 1
     *                       prediction_text: "Good conditions for oyster farming. Water quality parameters are within optimal ranges."
     *                       createdAt: "2024-01-01T00:00:00Z"
     *                       updatedAt: "2024-01-01T00:00:00Z"
     *                       Area:
     *                         id: 1
     *                         name: "Khu vực nuôi hàu A"
     *                     - id: 2
     *                       area_id: 2
     *                       user_id: 1
     *                       prediction_text: "Moderate conditions for cobia farming. Monitor water temperature closely."
     *                       createdAt: "2024-01-01T00:00:00Z"
     *                       updatedAt: "2024-01-01T00:00:00Z"
     *                       Area:
     *                         id: 2
     *                         name: "Khu vực nuôi cá cobia B"
     *                   count: 15
     *       401:
     *         description: Unauthorized
     *       403:
     *         description: Forbidden
 */
router.get(
  '/admin',
  authenticate,
  authorize(['admin', 'manager']),
  getAllPredictionsWithFilters
);

/**
 * @swagger
 * /predictions/{areaId}/latest:
 *   get:
 *     summary: Get latest prediction for an area (Public)
 *     tags: [Predictions]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: areaId
 *         required: true
 *         schema:
 *           type: integer
 *         description: Area ID
 *     responses:
 *       200:
 *         description: Latest prediction for the area
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Prediction'
 *       404:
 *         description: No prediction found for the area
 *       500:
 *         description: Server error
 */
router.get('/:areaId/latest', getLatestPrediction);

/**
 * @swagger
 * /predictions/{areaId}/history:
 *   get:
 *     summary: Get prediction history for an area (Public)
 *     tags: [Predictions]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: areaId
 *         required: true
 *         schema:
 *           type: integer
 *         description: Area ID
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Number of historical predictions to return
 *     responses:
 *       200:
 *         description: Prediction history for the area
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Prediction'
 *       404:
 *         description: Area not found
 *       500:
 *         description: Server error
 */
router.get('/:areaId/history', getPredictionHistory);

/**
 * @swagger
 * /predictions/{predictionId}:
 *   get:
 *     summary: Get prediction details by ID
 *     tags: [Predictions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: predictionId
 *         required: true
 *         schema:
 *           type: integer
 *         description: Prediction ID
 *     responses:
 *       200:
 *         description: Prediction details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Prediction'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Prediction not found
 */
router.get(
  '/:predictionId',
  authenticate,
  authorize(['expert', 'admin', 'manager']),
  getPredictionDetails
);

/**
 * @swagger
 * /predictions/user/{userId}:
 *   get:
 *     summary: Get predictions by user ID (Expert only)
 *     tags: [Predictions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: integer
 *         description: User ID
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Number of predictions per page
 *     responses:
 *       200:
 *         description: Predictions created by the user
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 predictions:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Prediction'
 *                 total:
 *                   type: integer
 *                 page:
 *                   type: integer
 *                 limit:
 *                   type: integer
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: User not found
 */
router.get(
  '/user/:userId',
  authenticate,
  authorize(['expert']),
  getPredictionsByUser
);

/**
 * @swagger
 * /predictions/chart/data:
 *   get:
 *     summary: Get prediction data for charts
 *     tags: [Predictions]
 *     parameters:
 *       - in: query
 *         name: area_id
 *         schema:
 *           type: integer
 *         description: Filter by area ID
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *         description: Number of days to include in chart data
 *     responses:
 *       200:
 *         description: Chart data for predictions
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 labels:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: ["2024-01-01", "2024-01-02", "2024-01-03"]
 *                 datasets:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       label:
 *                         type: string
 *                       data:
 *                         type: array
 *                         items:
 *                           type: number
 *       500:
 *         description: Server error
 */
router.get(
  '/chart/data',
  getPredictionChartData
);

/**
 * @swagger
 * /predictions/chart/all:
 *   get:
 *     summary: Get all prediction data for charts (all areas)
 *     tags: [Predictions]
 *     parameters:
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *         description: Number of days to include in chart data
 *     responses:
 *       200:
 *         description: Chart data for all predictions
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 areas:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       area_id:
 *                         type: integer
 *                       area_name:
 *                         type: string
 *                       data:
 *                         type: object
 *                         properties:
 *                           labels:
 *                             type: array
 *                             items:
 *                               type: string
 *                           datasets:
 *                             type: array
 *                             items:
 *                               type: object
 *       500:
 *         description: Server error
 */
router.get(
  '/chart/all',
  getAllPredictionChartData
);

module.exports = router;
