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
        as: 'Region',
        required: false,
        attributes: ['id', 'name', 'province'],
      },
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }
    options.order = [['region', 'DESC']];

    const areas = await Area.findAll(options);
    const total = await Area.count(options);
    res.status(200).json({ areas: areas, total: total });
  } catch (error) {
    console.error('Get All Areas Error:', {
      message: error.message,
      stack: error.stack,
      query: req.query,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.getAreaById = async (req, res) => {
  try {
    const { id } = req.params;
    const area = await Area.findOne({
      where: { id: id },
      include: {
        model: Region,
        as: 'Region',
        required: false,
      },
    });
    res.status(200).json(area);
  } catch (error) {
    console.error('Get Area By ID Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.id,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.createArea = async (req, res) => {
  try {
    const { name, latitude, longitude, region, area_type } = req.body;

    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    const newArea = await Area.create({
      name,
      latitude,
      longitude,
      region,
      area: 1000,
      area_type,
    });

    res.status(201).json(newArea);
  } catch (error) {
    console.error('Create Area Error:', {
      message: error.message,
      stack: error.stack,
      areaData: req.body,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.deleteArea = async (req, res) => {
  try {
    const { id } = req.params;
    const area = await Area.findOne({ where: { id } });

    if (!area) {
      return res.status(404).json({ error: 'Area not found.' });
    }

    console.log('Deleting area:', area.name);
    await area.destroy();

    res.status(200).json({ message: 'Area deleted successfully.' });
  } catch (error) {
    console.error('Delete Area Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.id,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.updateArea = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, latitude, longitude, region, area, area_type } = req.body;

    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    const selectedArea = await Area.findOne({ where: { id } });

    if (!selectedArea) {
      return res.status(404).json({ error: 'Area not found.' });
    }

    selectedArea.name = name || area.name;
    selectedArea.latitude = latitude || area.latitude;
    selectedArea.longitude = longitude || area.longitude;
    selectedArea.area = area || area.area;
    selectedArea.region = region || area.region;
    selectedArea.area_type = area_type;

    console.log('Updating area:', selectedArea.name);
    await selectedArea.save();

    res.status(200).json(selectedArea);
  } catch (error) {
    console.error('Update Area Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.id,
      updateData: req.body,
    });
    res.status(500).json({ error: error.message });
  }
};
