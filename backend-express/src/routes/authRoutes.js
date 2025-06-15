const express = require('express');
const {
  login,
  updateUserById,
  getAllUser,
  deactiveUser,
  createManagerUser,
  activateUser,
  deleteUser,
  getUserById,
  changePassword,
  //createAdminUser,
} = require('../controllers/authController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const router = express.Router();

router.post('/login', login);
router.post('/update/:id', authenticate, updateUserById);
router.get('/', authenticate, authorize(['admin', 'manager']), getAllUser);
router.patch(
  '/deactivate/:id',
  authenticate,
  authorize(['admin']),
  deactiveUser
);
router.patch('/activate/:id', authenticate, authorize(['admin']), activateUser);
router.post(
  '/create-user',
  authenticate,
  authorize(['admin']),
  createManagerUser
);

router.get('/user/:id', authenticate, getUserById);

router.delete(
  '/delete/:id',
  authenticate,
  authorize(['admin']), // chỉ admin mới được phép
  deleteUser
);
//router.post('/create-admin', createAdminUser);
router.post('/change-password/:id', authenticate, changePassword);
module.exports = router;
