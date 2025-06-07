const express = require('express');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const { getAllAreas, getAreaById,createArea,updateArea,deleteArea } = require('../controllers/areaController');
const { Province ,Area, District } = require('../models/index.js');
const router = express.Router();



router.get('/', getAllAreas);
router.get('/area/:id', getAreaById);
router.get('/provinces', async (req,res) => {return res.status(200).json(await Province.findAll())}); // Get areas by region
router.get('/districts', async (req,res) => {return res.status(200).json(await District.findAll())});
router.get('/area-list',authenticate,authorize(['admin']))
router.get('/district/:id', async (req,res) => { // Get areas by region ID
    const districtId = req.params.id;
    try {
        const areas = await Area.findAll({ where: { district : districtId } });
        return res.status(200).json(areas);
    } catch (error) {
        return res.status(500).json({ error: 'Error fetching areas by region ID' });
    }
}
)
router.get('/province/:id', async (req,res) => { // Get areas by region ID
    const provinceId = req.params.id;
    try {
        const areas = await Area.findAll({ where: { province : provinceId } });
        return res.status(200).json(areas);
    } catch (error) {
        return res.status(500).json({ error: 'Error fetching areas by region ID' });
    }
}
); // Get areas by region ID


router.post('/', authenticate, authorize(['admin','manager']), createArea);  // Create a new area

// PUT route to update an existing area (with authentication and authorization)
router.put('/:id', authenticate, authorize(['admin','manager']), updateArea);  // Update an existing area by ID

// DELETE route to delete an area (with authentication and authorization)
router.delete('/:id', authenticate, authorize(['admin','manager']), deleteArea); 
module.exports = router;
