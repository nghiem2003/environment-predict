const express = require('express');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const {
  getAllEmailSubscriptions,
  getEmailSubscriptionById,
  subscribeToPredictions,
  updateEmailSubscription,
  deleteEmailSubscription,
  unsubscribeFromPredictions,
  testEmail,
} = require('../controllers/emailController');

const router = express.Router();

// Get all email subscriptions (admin only)
router.get('/', authenticate, authorize(['admin']), getAllEmailSubscriptions);

// Get email subscription by ID (admin only)
router.get(
  '/:id',
  authenticate,
  authorize(['admin']),
  getEmailSubscriptionById
);

// Subscribe to prediction notifications (public endpoint)
router.post('/subscribe', subscribeToPredictions);

// Unsubscribe from prediction notifications (public endpoint)
router.get('/unsubscribe/:token', unsubscribeFromPredictions);

// Update email subscription (admin and manager)
router.put(
  '/:id',
  authenticate,
  authorize(['admin', 'manager']),
  updateEmailSubscription
);

// Delete email subscription (admin only)
router.delete(
  '/:id',
  authenticate,
  authorize(['admin']),
  deleteEmailSubscription
);

// Test email sending (admin only)
router.post('/test', authenticate, authorize(['admin']), testEmail);

module.exports = router;
