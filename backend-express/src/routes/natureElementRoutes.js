const express = require('express');
const {
    getAllNaturalElements,
    getNaturalElementById,
    createNaturalElement,
    updateNaturalElement,
    deleteNaturalElement,
    getNaturalElementsByCategory,
    getCategories,
    bulkUpdateNaturalElements,
} = require('../controllers/natureElementController');
const { authenticate, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

// Public routes (no authentication required)
router.get('/', getAllNaturalElements);
router.get('/categories', getCategories);
router.get('/category/:category', getNaturalElementsByCategory);
router.get('/:id', getNaturalElementById);

// Protected routes (require authentication)
router.post(
    '/',
    authenticate,
    authorize(['admin']),
    createNaturalElement
);

router.put(
    '/:id',
    authenticate,
    authorize(['admin']),
    updateNaturalElement
);

router.delete(
    '/:id',
    authenticate,
    authorize(['admin']),
    deleteNaturalElement
);

// Bulk operations (admin only)
router.post(
    '/bulk-update',
    authenticate,
    authorize(['admin']),
    bulkUpdateNaturalElements
);

module.exports = router;
