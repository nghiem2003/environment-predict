const express = require('express');
const {
  login,
  updateUserById,
  getAllUser,
  deactiveUser,
  createManagerUser,
  createAdminUser,
} = require('../controllers/authController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const router = express.Router();

router.post('/login', login);
router.post('/update/:id', authenticate, updateUserById);
router.get('/', authenticate, authorize(['admin']), getAllUser);
router.patch(
  '/deactivate/:id',
  authenticate,
  authorize(['admin']),
  deactiveUser
);
router.post(
  '/create-user',
  authenticate,
  authorize(['admin']),
  createManagerUser
);

router.post('/create-admin', createAdminUser);
module.exports = router;
