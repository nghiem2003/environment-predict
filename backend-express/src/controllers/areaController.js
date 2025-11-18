const { Op } = require('sequelize');
const { Area, Province, District, Prediction, PredictionNatureElement, sequelize } = require('../models');
const { sendPredictionNotification } = require('./emailController');
const logger = require('../config/logger');

const normalizeSearchTerm = (value = '') =>
  value
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');

const buildSearchCondition = (column, rawSearch) => {
  const normalized = normalizeSearchTerm(rawSearch);
  if (!normalized) return null;
  return sequelize.where(
    sequelize.fn('unaccent', sequelize.fn('lower', sequelize.col(column))),
    {
      [Op.like]: `%${normalized}%`,
    }
  );
};

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
    logger.debug('Get All Areas - Request query', req.query);

    // Start with an empty query object
    let query = {};

    // If a search term is provided, add it to the query (search by name)
    const searchCondition = buildSearchCondition('Area.name', search);
    if (searchCondition) {
      query[Op.and] = query[Op.and] || [];
      query[Op.and].push(searchCondition);
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

    // Filter by province and district if provided (for all users)
    if (province) {
      query.province = province; // UUID
    }
    if (district) {
      query.district = district; // UUID
    }

    // Manager-specific filter: if manager doesn't provide filter, apply their default scope
    if (role === 'manager' && !province && !district) {
      logger.debug('Manager role detected, applying default district/province filter');
      // Manager filter logic is handled by user's province/district from token
      // This is already handled in the query params passed from frontend
    }
    logger.debug('Query for Areas', { query });
    const options = {
      where: query,
      include: [
        {
          model: Province,
          as: 'Province',
          required: false,
          attributes: ['id', 'name', 'central_meridian'],
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
    logger.error('Get All Areas Error:', {
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
    logger.debug('Get All Areas (No Pagination) - Request query', req.query);

    let query = {};
    const searchCondition = buildSearchCondition('Area.name', search);
    if (searchCondition) {
      query[Op.and] = query[Op.and] || [];
      query[Op.and].push(searchCondition);
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
          attributes: ['id', 'name', 'central_meridian'],
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
    logger.error('Get All Areas (No Pagination) Error:', {
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
        attributes: ['id', 'name', 'central_meridian'],
      },
    });
    res.status(200).json(area);
  } catch (error) {
    logger.error('Get Area By ID Error:', {
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
    logger.error('Create Area Error:', {
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

    logger.info('Deleting area', { areaName: area.name, areaId: area.id });

    // Start a transaction to ensure all deletions succeed or fail together
    const transaction = await Area.sequelize.transaction();

    try {
      // First, delete all prediction-nature element relationships for this area's predictions
      const predictions = await Prediction.findAll({
        where: { area_id: id },
        transaction
      });

      for (const prediction of predictions) {
        await PredictionNatureElement.destroy({
          where: { prediction_id: prediction.id },
          transaction
        });
      }

      // Then delete all predictions for this area
      await Prediction.destroy({
        where: { area_id: id },
        transaction
      });

      // Finally delete the area itself
      await area.destroy({ transaction });

      // Commit the transaction
      await transaction.commit();

      logger.info('Successfully deleted area and all related predictions', { areaName: area.name, deletedPredictions: predictions.length });
      res.status(200).json({
        message: 'Area and all related predictions deleted successfully.',
        deletedArea: area.name,
        deletedPredictions: predictions.length
      });
    } catch (error) {
      // Rollback the transaction if anything fails
      await transaction.rollback();
      throw error;
    }
  } catch (error) {
    logger.error('Delete Area Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.id,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.updateArea = async (req, res) => {
  try {
    logger.debug('Update Area - Request body', req.body);

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

    logger.info('Updating area', { areaName: selectedArea.name, areaId: selectedArea.id });
    await selectedArea.save();

    // Note: Email notifications are now sent when predictions are created, not when areas are updated

    res.status(200).json(selectedArea);
  } catch (error) {
    logger.error('Update Area Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.id,
      updateData: req.body,
    });
    res.status(500).json({ error: error.message });
  }
};
