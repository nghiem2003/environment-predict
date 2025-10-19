const express = require('express');
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const { getAllAreas, getAllAreasNoPagination, getAreaById, createArea, updateArea, deleteArea } = require('../controllers/areaController');
const { Province, Area, District } = require('../models/index.js');
const router = express.Router();

/**
 * @swagger
 * /areas:
 *   get:
 *     summary: Get all areas (Admin/Manager/Expert only)
 *     tags: [Areas]
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
 *         description: Number of areas per page
 *       - in: query
 *         name: province
 *         schema:
 *           type: integer
 *         description: Filter by province ID
 *       - in: query
 *         name: district
 *         schema:
 *           type: integer
 *         description: Filter by district ID
 *       - in: query
 *         name: area_type
 *         schema:
 *           type: string
 *           enum: [oyster, shrimp, fish]
     *         description: Filter by area type
     *     responses:
     *       200:
     *         description: List of areas
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
     *                       id:
     *                         type: integer
     *                         description: Area ID
     *                         example: 1
     *                       name:
     *                         type: string
     *                         description: Area name
     *                         example: "Khu vực nuôi tôm A"
     *                       latitude:
     *                         type: number
     *                         format: double
     *                         description: Latitude coordinate
     *                         example: 10.762622
     *                       longitude:
     *                         type: number
     *                         format: double
     *                         description: Longitude coordinate
     *                         example: 106.660172
     *                       area:
     *                         type: number
     *                         format: double
     *                         description: Area size in square meters
     *                         example: 1000.5
     *                       province:
     *                         type: string
     *                         format: uuid
     *                         description: Province ID
     *                         example: "123e4567-e89b-12d3-a456-426614174000"
     *                       district:
     *                         type: string
     *                         format: uuid
     *                         description: District ID
     *                         example: "123e4567-e89b-12d3-a456-426614174001"
     *                       area_type:
     *                         type: string
     *                         enum: [oyster, cobia]
     *                         description: Type of aquaculture area
     *                         example: "oyster"
     *                 total:
     *                   type: integer
     *                   description: Total number of areas
     *                   example: 25
     *             examples:
     *               success:
     *                 summary: Successful response
     *                 value:
     *                   areas:
     *                     - id: 1
     *                       name: "Khu vực nuôi hàu A"
     *                       latitude: 10.762622
     *                       longitude: 106.660172
     *                       area: 1000.5
     *                       province: "123e4567-e89b-12d3-a456-426614174000"
     *                       district: "123e4567-e89b-12d3-a456-426614174001"
     *                       area_type: "oyster"
     *                     - id: 2
     *                       name: "Khu vực nuôi cá cobia B"
     *                       latitude: 10.800000
     *                       longitude: 106.700000
     *                       area: 1500.0
     *                       province: "123e4567-e89b-12d3-a456-426614174000"
     *                       district: "123e4567-e89b-12d3-a456-426614174002"
     *                       area_type: "cobia"
     *                   total: 25
     *       500:
     *         description: Server error
 */
router.get('/', authenticate, authorize(['admin', 'manager', 'expert']), getAllAreas);
/**
 * @swagger
 * /areas/all:
 *   get:
 *     summary: Get all areas without pagination (Public)
 *     tags: [Areas]
 *     security: []
 *     parameters:
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search by area name
 *       - in: query
 *         name: area_type
 *         schema:
 *           type: string
 *           enum: [oyster, shrimp, fish]
 *         description: Filter by area type
 *       - in: query
 *         name: province
 *         schema:
 *           type: integer
 *         description: Filter by province ID
 *       - in: query
 *         name: district
 *         schema:
 *           type: integer
 *         description: Filter by district ID
 *     responses:
 *       200:
 *         description: List of all areas
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
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       name:
 *                         type: string
 *                         example: "Khu vực nuôi tôm A"
 *                       latitude:
 *                         type: number
 *                         example: 10.762622
 *                       longitude:
 *                         type: number
 *                         example: 106.660172
 *                       area_type:
 *                         type: string
 *                         enum: [oyster, shrimp, fish]
 *                         example: "shrimp"
 *                       Province:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *                       District:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *       500:
 *         description: Server error
 */
router.get('/all', getAllAreasNoPagination);

/**
 * @swagger
 * /areas/area/{id}:
 *   get:
 *     summary: Get area by ID (Public)
 *     tags: [Areas]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Area ID
     *     responses:
     *       200:
     *         description: Area details
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 id:
     *                   type: integer
     *                   description: Area ID
     *                   example: 1
     *                 name:
     *                   type: string
     *                   description: Area name
     *                   example: "Khu vực nuôi hàu A"
     *                 latitude:
     *                   type: number
     *                   format: double
     *                   description: Latitude coordinate
     *                   example: 10.762622
     *                 longitude:
     *                   type: number
     *                   format: double
     *                   description: Longitude coordinate
     *                   example: 106.660172
     *                 area:
     *                   type: number
     *                   format: double
     *                   description: Area size in square meters
     *                   example: 1000.5
     *                 province:
     *                   type: string
     *                   format: uuid
     *                   description: Province ID
     *                   example: "123e4567-e89b-12d3-a456-426614174000"
     *                 district:
     *                   type: string
     *                   format: uuid
     *                   description: District ID
     *                   example: "123e4567-e89b-12d3-a456-426614174001"
     *                 area_type:
     *                   type: string
     *                   enum: [oyster, cobia]
     *                   description: Type of aquaculture area
     *                   example: "oyster"
     *             examples:
     *               success:
     *                 summary: Successful response
     *                 value:
     *                   id: 1
     *                   name: "Khu vực nuôi hàu A"
     *                   latitude: 10.762622
     *                   longitude: 106.660172
     *                   area: 1000.5
     *                   province: "123e4567-e89b-12d3-a456-426614174000"
     *                   district: "123e4567-e89b-12d3-a456-426614174001"
     *                   area_type: "oyster"
     *       404:
     *         description: Area not found
     *       500:
     *         description: Server error
 */
router.get('/area/:id', getAreaById);

/**
 * @swagger
 * /areas/provinces:
 *   get:
 *     summary: Get all provinces (Public)
 *     tags: [Areas]
 *     security: []
 *     responses:
 *       200:
 *         description: List of provinces
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   name:
 *                     type: string
 *       500:
 *         description: Server error
 */
router.get('/provinces', async (req, res) => { return res.status(200).json(await Province.findAll()) });

/**
 * @swagger
 * /areas/districts:
 *   get:
 *     summary: Get all districts (Public)
 *     tags: [Areas]
 *     security: []
 *     responses:
 *       200:
 *         description: List of districts
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   name:
 *                     type: string
 *                   province_id:
 *                     type: integer
 *       500:
 *         description: Server error
 */
router.get('/districts', async (req, res) => { return res.status(200).json(await District.findAll()) });

/**
 * @swagger
 * /areas/district/{id}:
 *   get:
 *     summary: Get areas by district ID (Public)
 *     tags: [Areas]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: District ID
 *     responses:
 *       200:
 *         description: List of areas in the district
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Area'
 *       500:
 *         description: Server error
 */
router.get('/district/:id', async (req, res) => {
    const districtId = req.params.id;
    try {
        const areas = await Area.findAll({ where: { district: districtId } });
        return res.status(200).json(areas);
    } catch (error) {
        return res.status(500).json({ error: 'Error fetching areas by region ID' });
    }
});

/**
 * @swagger
 * /areas/province/{id}:
 *   get:
 *     summary: Get areas by province ID (Public)
 *     tags: [Areas]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Province ID
 *     responses:
 *       200:
 *         description: List of areas in the province
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Area'
 *       500:
 *         description: Server error
 */
router.get('/province/:id', async (req, res) => {
    const provinceId = req.params.id;
    try {
        const areas = await Area.findAll({ where: { province: provinceId } });
        return res.status(200).json(areas);
    } catch (error) {
        return res.status(500).json({ error: 'Error fetching areas by region ID' });
    }
});

/**
 * @swagger
 * /areas:
 *   post:
 *     summary: Create new area
 *     tags: [Areas]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - latitude
 *               - longitude
 *               - province
 *             properties:
 *               name:
 *                 type: string
 *                 example: "Khu vực nuôi tôm A"
 *               latitude:
 *                 type: number
 *                 format: float
 *                 example: 10.762622
 *               longitude:
 *                 type: number
 *                 format: float
 *                 example: 106.660172
 *               province:
 *                 type: integer
 *                 example: 1
 *               district:
 *                 type: integer
 *                 example: 1
 *               area_type:
 *                 type: string
 *                 enum: [oyster, shrimp, fish]
 *                 example: "shrimp"
 *     responses:
 *       201:
 *         description: Area created successfully
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
router.post('/', authenticate, authorize(['admin', 'manager']), createArea);

/**
 * @swagger
 * /areas/{id}:
 *   put:
 *     summary: Update area by ID
 *     tags: [Areas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Area ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               latitude:
 *                 type: number
 *                 format: float
 *               longitude:
 *                 type: number
 *                 format: float
 *               province:
 *                 type: integer
 *               district:
 *                 type: integer
 *               area_type:
 *                 type: string
 *                 enum: [oyster, shrimp, fish]
 *     responses:
 *       200:
 *         description: Area updated successfully
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
 *       404:
 *         description: Area not found
 */
router.put('/:id', authenticate, authorize(['admin', 'manager']), updateArea);

/**
 * @swagger
 * /areas/{id}:
 *   delete:
 *     summary: Delete area by ID
 *     tags: [Areas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Area ID
 *     responses:
 *       200:
 *         description: Area deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Success'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 *       404:
 *         description: Area not found
 */
router.delete('/:id', authenticate, authorize(['admin', 'manager']), deleteArea);

module.exports = router;
