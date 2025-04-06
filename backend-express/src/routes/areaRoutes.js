const express = require('express');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const { getAllAreas, getAreaById,createArea,updateArea,deleteArea } = require('../controllers/areaController');
const router = express.Router();

router.get('/', getAllAreas);
router.get('/:id', getAreaById);
router.get('/area-list',authenticate,authorize(['admin']))

router.post('/', authenticate, authorize(['admin']), createArea);  // Create a new area

// PUT route to update an existing area (with authentication and authorization)
router.put('/:id', authenticate, authorize(['admin']), updateArea);  // Update an existing area by ID

// DELETE route to delete an area (with authentication and authorization)
router.delete('/:id', authenticate, authorize(['admin']), deleteArea); 
module.exports = router;
