const { Area } = require('../models');

exports.getAllAreas = async (req, res) => {
  try {
    const areas = await Area.findAll();
    res.json(areas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAreaById = async (req, res) => {
  try {
    const { id } = req.params; // Extract ID from request parameters
    const area = await Area.findOne({ where: { id: id } }); // Query database by ID
    res.json(area);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
