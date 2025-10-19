const { Op } = require('sequelize');
const { Area, Province, District } = require('../models');
const { sendPredictionNotification } = require('./emailController');

exports.getAllAreas = async (req, res) => {
  try {
    const {
      search,
      area_type,
      lat_min,
      lat_max,
      long_min,
      long_max,
      limit = 10,
      offset = 0,
      role,
      district,
      province,
    } = req.query;
    console.log(req.query);

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
    if (role === 'manager') {
      console.log('Manager role detected, applying district filter');
      if (district) {
        query.district = district; // lọc theo district
      } else if (province) {
        query.province = province; // lọc theo province nếu không có district
      }
    }
    console.log('Query for Areas:', query);
    const options = {
      where: query,
      include: [
        {
          model: Province,
          as: 'Province',
          required: false,
          attributes: ['id', 'name'],
        },
        {
          model: District,
          as: 'District',
          required: false,
          attributes: ['id', 'name'],
        },
      ],
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }
    options.order = [['name', 'DESC']];

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

// Get all areas without pagination (for dropdowns, selects, etc.)
exports.getAllAreasNoPagination = async (req, res) => {
  try {
    const { search, area_type, lat_min, lat_max, long_min, long_max, province, district } = req.query;
    console.log(req.query);

    let query = {};
    if (search) {
      query.name = {
        [Op.iLike]: `%${search}%`,
      };
    }
    if (area_type) {
      query.area_type = area_type;
    }
    if (lat_min && lat_max) {
      query.latitude = {
        [Op.between]: [parseFloat(lat_min), parseFloat(lat_max)],
      };
    }
    if (long_min && long_max) {
      query.longitude = {
        [Op.between]: [parseFloat(long_min), parseFloat(long_max)],
      };
    }
    if (province) {
      query.province = province;
    }
    if (district) {
      query.district = district;
    }

    const options = {
      where: query,
      include: [
        {
          model: Province,
          as: 'Province',
          required: false,
          attributes: ['id', 'name'],
        },
        {
          model: District,
          as: 'District',
          required: false,
          attributes: ['id', 'name'],
        },
      ],
      order: [['name', 'ASC']],
    };

    const areas = await Area.findAll(options);
    res.status(200).json({ areas: areas });
  } catch (error) {
    console.error('Get All Areas (No Pagination) Error:', {
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
        model: Province,

        as: 'Province',
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
    const { name, latitude, longitude, province, district, area_type } =
      req.body;

    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    // Validate province/district relationship
    if (province) {
      const provinceObj = await Province.findOne({ where: { id: province } });
      if (!provinceObj) {
        return res.status(400).json({ error: 'Province not found' });
      }
    }
    if (district) {
      const districtObj = await District.findOne({ where: { id: district } });
      if (!districtObj) {
        return res.status(400).json({ error: 'District not found' });
      }
      if (province && String(districtObj.province_id) !== String(province)) {
        return res
          .status(400)
          .json({ error: 'District does not belong to the selected province' });
      }
    }

    const newArea = await Area.create({
      name,
      latitude,
      longitude,
      province,
      district,
      area: 1000,
      area_type,
    });

    // Note: Email notifications are now sent when predictions are created, not when areas are created

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

    // Note: Email notifications are now sent when predictions are created, not when areas are deleted

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
    console.log(req.body);

    const { id } = req.params;
    const { name, latitude, longitude, province, district, area, area_type } =
      req.body;

    if (area_type !== 'oyster' && area_type !== 'cobia') {
      return res.status(400).json({
        error: 'Invalid area_type. It must be either "oyster" or "cobia".',
      });
    }

    const selectedArea = await Area.findOne({ where: { id } });

    if (!selectedArea) {
      return res.status(404).json({ error: 'Area not found.' });
    }

    // If province/district are being updated, validate the relationship
    if (province) {
      const provinceObj = await Province.findOne({ where: { id: province } });
      if (!provinceObj) {
        return res.status(400).json({ error: 'Province not found' });
      }
    }
    if (district) {
      const districtObj = await District.findOne({ where: { id: district } });
      if (!districtObj) {
        return res.status(400).json({ error: 'District not found' });
      }
      const effectiveProvince = province || selectedArea.province;
      if (effectiveProvince && String(districtObj.province_id) !== String(effectiveProvince)) {
        return res
          .status(400)
          .json({ error: 'District does not belong to the selected province' });
      }
    }

    selectedArea.name = name || selectedArea.name;
    selectedArea.latitude = latitude || selectedArea.latitude;
    selectedArea.longitude = longitude || selectedArea.longitude;
    selectedArea.area = area || selectedArea.area;
    selectedArea.province = province || selectedArea.province;
    selectedArea.district = district || selectedArea.district;
    selectedArea.area_type = area_type;

    console.log('Updating area:', selectedArea.name);
    await selectedArea.save();

    // Note: Email notifications are now sent when predictions are created, not when areas are updated

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
