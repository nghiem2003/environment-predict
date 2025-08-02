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
  sendOTP,
  verifyOTPAndSubscribe,
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

// Send OTP for email subscription (public endpoint)
router.post('/send-otp', sendOTP);

// Verify OTP and subscribe (public endpoint)
router.post('/verify-otp', verifyOTPAndSubscribe);

// Subscribe to prediction notifications (public endpoint) - legacy
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
