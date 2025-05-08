const { Op } = require('sequelize');
const { Area } = require('../models');
const { Region } = require('../models');
exports.getAllAreas = async (req, res) => {
  try {
    const {
      search,
      area_type,
      lat_min,
      lat_max,
      long_min,
      long_max,
      limit,
      offset,
    } = req.query;

    // Start with an empty query object
    let query = {};

    // If a search term is provided, add it to the query (search by name)
    if (search) {
      query.name = { [Op.like]: `%${search}%` }; // Sequelize query for partial match
    }

    // If area_type is provided, filter by area type
    if (area_type) {
      query.area_type = area_type;
    }

    // If latitude range is provided, filter by latitudes
    if (lat_min || lat_max) {
      query.latitude = {}; // Adjusted for the correct column name
      if (lat_min) query.latitude[Op.gte] = lat_min; // Greater than or equal to lat_min
      if (lat_max) query.latitude[Op.lte] = lat_max; // Less than or equal to lat_max
    }

    // If longitude range is provided, filter by longitudes
    if (long_min || long_max) {
      query.longitude = {}; // Adjusted for the correct column name
      if (long_min) query.longitude[Op.gte] = long_min; // Greater than or equal to long_min
      if (long_max) query.longitude[Op.lte] = long_max; // Less than or equal to long_max
    }

    const options = {
      where: query,
      include: {
        model: Region,
        as: 'Region', // This should match the alias used in your association
        required: false, // If you want to include Areas even if they don't have an associated Region
        attributes: ['id', 'name', 'province'], // Specify the attributes you want to include from the Region model
      },
    };

    if (limit) {
      options.limit = parseInt(limit, 10); // Convert limit to an integer
    }
    if (offset) {
      options.offset = parseInt(offset, 10); // Convert offset to an integer
    }
    options.order = [['region', 'DESC']];
    // Query the database with the built query object
    const areas = await Area.findAll(options);
    const total = await Area.count(options); // Count total records matching the query
    // Return the areas as a response
    res.status(200).json({ areas: areas, total: total }); // Return areas and total count
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAreaById = async (req, res) => {
  try {
    const { id } = req.params; // Extract ID from request parameters
    const area = await Area.findOne({
      where: { id: id },
      include: {
        model: Region,
        as: 'Region', // This should match the alias used in your association
        required: false, // If you want to include Areas even if they don't have an associated Region
      },
    }); // Query database by ID
    res.status(200).json(area);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

exports.createArea = async (req, res) => {
  try {
    const { name, latitude, longitude, region, area_type } = req.body;

    // Validate area_type (must be either 'oyster' or 'cobia')
    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    // Create the new area in the database
    const newArea = await Area.create({
      name,
      latitude,
      longitude,
      region,
      area: 1000,
      area_type,
    });

    // Return the newly created area
    res.status(201).json(newArea);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Function to delete an Area by ID
exports.deleteArea = async (req, res) => {
  try {
    const { id } = req.params;

    // Find the area by ID
    const area = await Area.findOne({ where: { id } });
    console.log(area.name);

    if (!area) {
      return res.status(404).json({ error: 'Area not found.' });
    }

    // Delete the area
    await area.destroy();

    res.status(200).json({ message: 'Area deleted successfully.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Function to update an Area by ID
exports.updateArea = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, latitude, longitude, region, area, area_type } = req.body;

    // Validate area_type (must be either 'oyster' or 'cobia')
    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    // Find the area by ID
    const selectedArea = await Area.findOne({ where: { id } });

    if (!selectedArea) {
      return res.status(404).json({ error: 'Area not found.' });
    }

    // Update the area
    selectedArea.name = name || area.name;
    selectedArea.latitude = latitude || area.latitude;
    selectedArea.longitude = longitude || area.longitude;
    selectedArea.area = area || area.area;
    selectedArea.region = region || area.region;
    selectedArea.area_type = area_type;

    // Save the updated area
    await selectedArea.save();
    console.log(selectedArea);

    res.status(200).json(selectedArea);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
