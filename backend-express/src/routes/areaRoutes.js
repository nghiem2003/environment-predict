const express = require('express');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const { getAllAreas, getAreaById,createArea,updateArea,deleteArea } = require('../controllers/areaController');
const Region = require('../models/Region.js')
const Area = require('../models/Area.js')
const router = express.Router();

router.get('/', getAllAreas);
router.get('/regions', async (req,res) => {return res.status(200).json(await Region.findAll())}); // Get areas by region
router.get('/:id', getAreaById);
router.get('/area-list',authenticate,authorize(['admin']))
router.get('/region/:id', async (req,res) => { // Get areas by region ID
    const regionId = req.params.id;
    try {
        const areas = await Area.findAll({ where: { region:regionId } });
        return res.status(200).json(areas);
    } catch (error) {
        return res.status(500).json({ error: 'Error fetching areas by region ID' });
    }
}
); // Get areas by region ID


router.post('/', authenticate, authorize(['admin']), createArea);  // Create a new area

// PUT route to update an existing area (with authentication and authorization)
router.put('/:id', authenticate, authorize(['admin']), updateArea);  // Update an existing area by ID

// DELETE route to delete an area (with authentication and authorization)
router.delete('/:id', authenticate, authorize(['admin']), deleteArea); 
module.exports = router;
