const {
  Prediction,
  PredictionNatureElement,
  NatureElement,
  Area,
  User,
  Province,
  District,
} = require('../models');
const { Op } = require('sequelize');
require('dotenv').config();
const axios = require('axios');
const { sendPredictionNotification } = require('./emailController');
const xlsx = require('xlsx');
const { parseExcel2 } = require('../services/importService');
const logger = require('../config/logger');

// Required fields for prediction model - only these should be saved to database
const REQUIRED_FIELDS = [
  'R_PO4', 'O2Sat', 'O2ml_L', 'STheta', 'Salnty', 'R_DYNHT', 'T_degC',
  'R_Depth', 'Distance', 'Wind_Spd', 'Wave_Ht', 'Wave_Prd', 'IntChl', 'Dry_T'
];

// Helper function to create prediction without Express req/res
async function createPredictionInternal(userId, areaId, inputs, modelName, createdAt = null) {
  const area = await Area.findByPk(areaId);
  if (!area) {
    throw new Error('Area not found');
  }

  // Filter inputs to only include required fields for the model
  const filteredInputs = {};
  const skippedFields = [];
  for (const [key, value] of Object.entries(inputs)) {
    if (REQUIRED_FIELDS.includes(key)) {
      filteredInputs[key] = Number.parseFloat(value);
    } else {
      skippedFields.push(key);
    }
  }

  if (skippedFields.length > 0) {
    logger.debug(`[Prediction] Filtered out non-required fields: ${skippedFields.join(', ')}`);
  }

  // Prepare request data for Flask API - only include REQUIRED_FIELDS + lat/lon
  const flaskRequestData = {};
  REQUIRED_FIELDS.forEach(field => {
    if (filteredInputs[field] != null) {
      flaskRequestData[field] = filteredInputs[field];
    }
  });
  flaskRequestData.lat = area.latitude;
  flaskRequestData.lon = area.longitude;

  const endpoint = modelName.includes('oyster')
    ? '/predict/oyster'
    : '/predict/cobia';
  const flaskUrl = `${process.env.FLASK_API_URL}${endpoint}`;

  let flaskResponse;
  try {
    flaskResponse = await axios.post(flaskUrl, flaskRequestData, {
      params: { model: modelName },
    });
  } catch (axiosError) {
    logger.error('[Prediction] Flask API error', {
      message: axiosError.message,
      status: axiosError.response?.status,
      data: axiosError.response?.data,
      url: flaskUrl
    });
    throw new Error(axiosError.response?.data?.error || axiosError.message || 'Flask API error');
  }

  // Check HTTP status code
  if (flaskResponse.status >= 400) {
    logger.error('[Prediction] Flask returned error status', { status: flaskResponse.status, data: flaskResponse.data });
    throw new Error(flaskResponse.data?.error || 'Flask API returned error status');
  }

  const flaskResult = flaskResponse.data;
  if (flaskResult.error) {
    logger.error('[Prediction] Flask response contains error', { error: flaskResult.error });
    throw new Error(flaskResult.error);
  }

  const { prediction_result } = flaskResult;

  const predictionData = {
    user_id: userId,
    area_id: areaId,
    prediction_text: prediction_result.prediction,
  };

  if (createdAt && !isNaN(new Date(createdAt).getTime())) {
    const customDate = new Date(createdAt);
    predictionData.createdAt = customDate;
    predictionData.updatedAt = customDate;
    logger.debug('[Prediction] Using custom createdAt', { createdAt: customDate });
  }

  const predictionRecord = await Prediction.create(predictionData);
  logger.info('[Prediction] Created prediction record in database', {
    predictionId: predictionRecord.id,
    areaId,
    userId
  });

  // Save filtered inputs
  let savedElements = 0;
  for (const [elementName, value] of Object.entries(filteredInputs)) {
    const entry = await NatureElement.findOne({
      where: { name: elementName },
    });

    if (!entry) {
      logger.warn(`[Prediction] NatureElement not found: ${elementName}`);
      continue;
    }

    await PredictionNatureElement.create({
      prediction_id: predictionRecord.id,
      nature_element_id: entry.id,
      value,
    });
    savedElements++;
  }

  logger.info(`[Prediction] Saved ${savedElements} nature elements to database`);

  return {
    prediction_id: predictionRecord.id,
    prediction_text: prediction_result.prediction,
    model_used: modelName,
  };
}

exports.createPrediction = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const { areaId, inputs, modelName } = req.body;

    const result = await createPredictionInternal(
      userId,
      areaId,
      inputs,
      modelName,
      req.body.createdAt
    );

    // Send email notification to subscribers
    try {
      await sendPredictionNotification(areaId, {
        result: result.prediction_text,
        model: modelName,
        predictionId: result.prediction_id,
      });
    } catch (emailError) {
      logger.error('Failed to send prediction notification', { error: emailError.message });
    }

    res.json(result);
  } catch (error) {
    logger.error('Create Prediction Error', {
      message: error.message,
      stack: error.stack,
      requestData: req.body,
      flaskUrl: process.env.FLASK_API_URL,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.getLatestPrediction = async (req, res) => {
  try {
    const { areaId } = req.params;
    logger.debug('Fetching latest prediction for area', { areaId });
    const area = await Area.findByPk(areaId);
    if (!area)
      return res.status(404).json({ error: 'Area not found' });
    const prediction = await Prediction.findOne({
      where: { area_id: areaId },
      order: [['id', 'DESC']],
      include: [
        {
          model: NatureElement,
          attributes: ['id', 'name', 'description', 'unit'],
          through: {
            model: PredictionNatureElement,
            attributes: ['value'],
          },
        },
      ],
    });

    if (!prediction)
      return res.status(200).json({ prediction: null, message: 'No predictions found' });

    res.json(prediction);
  } catch (error) {
    logger.error('Get Latest Prediction Error', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.areaId,
    });
    res.status(500).json({ error: error.message });
  }
};

// Get prediction history for an area within last N days (default 14)
exports.getPredictionHistory = async (req, res) => {
  try {
    const { areaId } = req.params;
    const days = Number.parseInt(req.query.days, 10) || 14;
    const since = new Date();
    since.setDate(since.getDate() - days);

    const predictions = await Prediction.findAll({
      where: {
        area_id: areaId,
        createdAt: { [Op.gte]: since },
      },
      order: [['createdAt', 'ASC']],
      include: [
        {
          model: NatureElement,
          attributes: ['id', 'name', 'description', 'unit'],
          through: { model: PredictionNatureElement, attributes: ['value'] },
        },
      ],
    });

    res.json({ areaId, days, predictions });
  } catch (error) {
    logger.error('Get Prediction History Error', {
      message: error.message,
      stack: error.stack,
      areaId: req.params.areaId,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.getPredictionDetails = async (req, res) => {
  try {
    const { predictionId } = req.params;
    logger.debug('Fetching prediction details for ID', { predictionId });

    const prediction = await Prediction.findOne({
      where: { id: predictionId },
      attributes: ['id', 'user_id', 'area_id', 'prediction_text', 'createdAt', 'updatedAt'],
      include: [
        {
          model: Area,
          as: 'Area',
          attributes: [
            'id',
            'name',
            'latitude',
            'longitude',
            'area',
            'province',
            'district',
            'area_type',
          ],
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false, // Don't filter out predictions without nature elements
        },
      ],
    });

    if (!prediction) {
      return res.status(404).json({ error: 'Prediction not found' });
    }

    // Kiểm tra quyền của manager
    if (req.user.role === 'manager') {
      const userProvince = req.user.province;
      const userDistrict = req.user.district;

      if (userDistrict) {
        // Manager cấp quận - chỉ xem dự đoán của quận đó
        if (prediction.Area.district !== userDistrict) {
          return res.status(403).json({
            error:
              'Access denied. You can only view predictions in your district.',
          });
        }
      } else if (userProvince) {
        // Manager cấp tỉnh - xem dự đoán của tỉnh đó
        if (prediction.Area.province !== userProvince) {
          return res.status(403).json({
            error:
              'Access denied. You can only view predictions in your province.',
          });
        }
      } else {
        return res.status(403).json({
          error: 'Manager must be assigned to a province or district.',
        });
      }
    }

    res.json(prediction);
  } catch (error) {
    logger.error('Get Prediction Details Error', {
      message: error.message,
      stack: error.stack,
      predictionId: req.params.predictionId,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllPredictionsWithFilters = async (req, res) => {
  try {
    logger.debug('Fetching all predictions with filters', req.query);

    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res
        .status(403)
        .json({ error: 'Access denied. Admins and managers only.' });
    }

    const {
      userId = undefined,
      areaId = undefined,
      limit = 10,
      offset = 0,
    } = req.query;

    const options = {
      attributes: ['id', 'user_id', 'area_id', 'prediction_text', 'createdAt', 'updatedAt'],
      include: [
        {
          model: User,
          attributes: ['id', 'username', 'email', 'role'],
        },
        {
          model: Area,
          attributes: [
            'id',
            'name',
            'latitude',
            'longitude',
            'area',
            'area_type',
            'province',
            'district',
          ],
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
      ],
      order: [['createdAt', 'DESC']],
      distinct: true, // Required for accurate count with multiple includes
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const where = {};
    if (userId) where.user_id = parseInt(userId, 10);
    if (areaId) where.area_id = parseInt(areaId, 10);

    // Nếu là manager, chỉ cho phép xem dự đoán trong phạm vi quản lý
    if (req.user.role === 'manager') {
      const userProvince = req.user.province;
      const userDistrict = req.user.district;

      if (userDistrict) {
        // Manager cấp quận - chỉ xem dự đoán của quận đó
        where['$Area.district$'] = userDistrict;
        // Ensure Area is required for the filter to work
        options.include[1].required = true;
      } else if (userProvince) {
        // Manager cấp tỉnh - xem dự đoán của tỉnh đó
        where['$Area.province$'] = userProvince;
        // Ensure Area is required for the filter to work
        options.include[1].required = true;
      } else {
        return res.status(403).json({
          error: 'Manager must be assigned to a province or district.',
        });
      }
    }

    options.where = where;

    const predictions = await Prediction.findAndCountAll(options);
    if (predictions.rows.length === 0) {
      logger.debug('No predictions found with filters', req.query);
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
    }
    res.json(predictions);
  } catch (error) {
    logger.error('Get All Predictions With Filters Error:', {
      message: error.message,
      stack: error.stack,
      query: req.query,
      userRole: req.user?.role,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getPredictionsByUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10, offset = 0, areaId = undefined } = req.query;

    logger.debug('Fetching predictions for user', { userId, pagination: { limit, offset }, areaId });

    const options = {
      attributes: ['id', 'user_id', 'area_id', 'prediction_text', 'createdAt', 'updatedAt'],
      include: [
        {
          model: User,
          attributes: ['id', 'username', 'email', 'role'],
        },
        {
          model: Area,
          attributes: [
            'id',
            'name',
            'latitude',
            'longitude',
            'area',
            'area_type',
            'province',
            'district',
          ],
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false, // Don't filter out predictions without nature elements
        },
      ],
      order: [['createdAt', 'DESC']],
      distinct: true, // Required for accurate count with multiple includes and many-to-many relationships
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const where = { user_id: parseInt(userId, 10) };
    if (areaId) {
      where.area_id = parseInt(areaId, 10);
    }
    options.where = where;

    const predictions = await Prediction.findAndCountAll(options);

    if (predictions.rows.length === 0) {
      logger.debug('No predictions found for user', { userId });
      return res.json({ rows: [], count: 0 });
    }
    res.json(predictions);
  } catch (error) {
    logger.error('Get Predictions By User Error', {
      message: error.message,
      stack: error.stack,
      userId: req.params.userId,
      pagination: req.query,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.createBatchPrediction = async (req, res) => {
  logger.info('Batch Processing');

  const userId = req.user?.id || req.body.userId;
  const { areaId, modelName, data } = req.body;
  try {
    const endpoint = modelName.includes('oyster')
      ? '/predict/oyster'
      : '/predict/cobia';
    const flaskUrl = `${process.env.FLASK_API_URL}${endpoint}`;

    const predictionsResult = [];

    const area = await Area.findByPk(areaId);
    for (const inputs of data) {
      // Filter inputs to only include required fields for the model
      const filteredInputs = {};
      const skippedFields = [];
      let createdAt = null;

      for (const [key, value] of Object.entries(inputs)) {
        if (key === 'createdAt') {
          createdAt = value; // preserve date separately
        } else if (REQUIRED_FIELDS.includes(key)) {
          filteredInputs[key] = Number.parseFloat(value);
        } else {
          skippedFields.push(key);
        }
      }

      if (skippedFields.length > 0) {
        logger.debug(`[BatchPrediction] Filtered out non-required fields: ${skippedFields.join(', ')}`);
      }
      logger.debug(`[BatchPrediction] Filtered inputs (${Object.keys(filteredInputs).length} fields)`, filteredInputs);

      // Prepare request data for Flask API - only include REQUIRED_FIELDS + lat/lon
      const flaskRequestData = {};
      REQUIRED_FIELDS.forEach(field => {
        if (filteredInputs[field] != null) {
          flaskRequestData[field] = filteredInputs[field];
        }
      });
      if (area) {
        flaskRequestData.lat = area.latitude;
        flaskRequestData.lon = area.longitude;
      }
      logger.debug('[BatchPrediction] Flask request data (REQUIRED_FIELDS + lat/lon)', flaskRequestData);

      let flaskResponse;
      try {
        flaskResponse = await axios.post(flaskUrl, flaskRequestData, {
          params: { model: modelName },
        });
      } catch (axiosError) {
        logger.error('[BatchPrediction] Flask API error', {
          message: axiosError.message,
          status: axiosError.response?.status,
          data: axiosError.response?.data,
          url: flaskUrl,
          recordIndex: data.indexOf(inputs)
        });
        throw new Error(`Flask API error: ${axiosError.response?.data?.error || axiosError.message || 'Unknown error'}`);
      }

      // Check HTTP status code
      if (flaskResponse.status >= 400) {
        logger.error('[BatchPrediction] Flask returned error status', { status: flaskResponse.status, data: flaskResponse.data });
        throw new Error(`Flask API returned error status ${flaskResponse.status}: ${JSON.stringify(flaskResponse.data?.error || flaskResponse.data)}`);
      }

      const flaskResult = flaskResponse.data;
      if (flaskResult.error) {
        logger.error('[BatchPrediction] Flask response contains error', { error: flaskResult.error });
        throw new Error(`Flask API error: ${flaskResult.error}`);
      }

      const { prediction_result } = flaskResult;

      // Tạo prediction với timestamp tùy chỉnh nếu có, nếu không thì để Sequelize tự tạo
      const predictionData = {
        user_id: userId,
        area_id: areaId,
        prediction_text: prediction_result.prediction,
      };

      // Nếu có createdAt từ input, sử dụng nó
      if (createdAt && !isNaN(new Date(createdAt).getTime())) {
        const customDate = new Date(createdAt);
        predictionData.createdAt = customDate;
        predictionData.updatedAt = customDate;
        logger.debug('Using custom timestamp', { customDate });
      } else {
        logger.debug('Using current timestamp (Sequelize auto)');
      }

      const predictionRecord = await Prediction.create(predictionData);
      logger.debug('New prediction created', { predictionId: predictionRecord.id });

      // Save filtered inputs (already filtered above)
      for (const [elementName, value] of Object.entries(filteredInputs)) {
        const entry = await NatureElement.findOne({
          where: { name: elementName },
        });

        if (!entry) {
          logger.warn(`[BatchPrediction] NatureElement not found: ${elementName}`);
          continue;
        }

        await PredictionNatureElement.create({
          prediction_id: predictionRecord.id,
          nature_element_id: entry.id,
          value: value,
        });
      }
      logger.info(`[BatchPrediction] Saved ${Object.keys(filteredInputs).length} nature elements to database`);
      logger.debug('Batch prediction processing completed');

      predictionsResult.push({
        prediction_id: predictionRecord.id,
        prediction_text: prediction_result.prediction,
        inputs,
      });
    }

    // Send email notification to subscribers for batch predictions
    try {
      await sendPredictionNotification(areaId, {
        result: `Đã tạo ${predictionsResult.length} dự đoán mới`,
        model: modelName,
        predictionCount: predictionsResult.length,
        batchPrediction: true
      });
    } catch (emailError) {
      logger.error('Failed to send batch prediction notification', { error: emailError.message });
    }

    res.json({ predictions: predictionsResult, model_used: modelName });
  } catch (error) {
    logger.error('Batch prediction error', { error: error.message, stack: error.stack });

    res.status(500).json({ error: error.message });
  }
};

// New: parse uploaded Excel and forward rows to batch prediction
exports.createBatchPredictionFromExcel = async (req, res) => {
  try {


    const { userId, areaId, modelName } = req.body;
    if (!req.file) return res.status(400).json({ error: 'Excel file is required (field name: file)' });
    if (!userId || !areaId || !modelName) return res.status(400).json({ error: 'userId, areaId, modelName are required' });

    // Parse workbook from buffer
    const wb = xlsx.read(req.file.buffer, { type: 'buffer' });
    const sheetName = req.body.sheetName || wb.SheetNames[0];
    const ws = wb.Sheets[sheetName];
    if (!ws) return res.status(400).json({ error: `Sheet '${sheetName}' not found` });

    // Convert to JSON (object rows and matrix) for flexible parsing
    const rowsObjects = xlsx.utils.sheet_to_json(ws, { defval: null, raw: true });
    const rowsMatrix = xlsx.utils.sheet_to_json(ws, { header: 1, defval: null, raw: true });
    logger.info('[Excel] sheetName:', { sheetName });
    logger.info('[Excel] rowsObjects length:', { length: rowsObjects.length });
    logger.info('[Excel] rowsMatrix dims:', { rows: rowsMatrix.length, cols: rowsMatrix[0] ? rowsMatrix[0].length : 0 });
    if (!rowsObjects.length && (!rowsMatrix || !rowsMatrix.length)) {
      return res.status(400).json({ error: 'Sheet is empty' });
    }

    const required = ['R_PO4', 'O2Sat', 'O2ml_L', 'STheta', 'Salnty', 'R_DYNHT', 'T_degC', 'R_Depth', 'Distance', 'Wind_Spd', 'Wave_Ht', 'Wave_Prd', 'IntChl', 'Dry_T'];
    const norm = (s) => (s || '').toString().toLowerCase()
      .normalize('NFD').replace(/\p{Diacritic}/gu, '')
      .replace(/[^a-z0-9]+/g, ' ').trim();
    const mapHeaderToFeature = (h) => {
      const n = norm(h);
      if (/oxy.*hoa.*tan|dissolved.*oxygen|o2\b/.test(n)) return 'O2ml_L';
      if (/nhiet.*do.*nuoc.*bien|nhiet.*do(?!\s*khong)|temperature/.test(n)) return 'T_degC';
      if (/do.*man|salinity/.test(n)) return 'Salnty';
      if (/wave.*height|vhm0|chieu.*cao/.test(n)) return 'Wave_Ht';
      if (/wave.*period|vtpk|chu.*ky/.test(n)) return 'Wave_Prd';
      if (/chlor|chl/.test(n)) return 'IntChl';
      if (/po4|photphat|phosphate/.test(n)) return 'R_PO4';
      return null;
    };

    let normalized = [];
    // Try wide format mapping
    if (rowsObjects.length) {
      const headerMap = {};
      Object.keys(rowsObjects[0]).forEach(h => headerMap[h] = mapHeaderToFeature(h));
      if (Object.values(headerMap).some(Boolean)) {
        logger.info('[Excel] Wide header map -> feature:', { headerMap });
        normalized = rowsObjects.map((r) => {
          const obj = {};
          for (const [h, v] of Object.entries(r)) {
            const feat = headerMap[h];
            if (!feat) continue;
            let num = v === '' || v === null || v === undefined ? null : Number(v);
            if (feat === 'O2ml_L') {
              const unitHint = norm(h);
              if (/mg\s*\/\s*l/.test(unitHint)) num = num != null ? num / 1.429 : null;
            }
            if (num !== null && !isNaN(num)) obj[feat] = num;
          }
          const createdAtKey = Object.keys(r).find(k => /created|date|ngay|thoi gian/.test(norm(k)));
          if (createdAtKey) obj.createdAt = r[createdAtKey];
          return obj;
        }).filter(o => Object.keys(o).length > 0);
      }
    }

    // Try strict fixed-format like provided: row3 months, row6+ fixed param names in col1, col2 units, col3+ values (hard-coded rows)
    if (!normalized.length && rowsMatrix && rowsMatrix.length >= 4) {
      // Fixed per provided sheet: header row is 5 (0-based 4). Still try nearby rows if needed
      let headerRow = 4;
      const tryRows = [4, 3, 2, 5];
      for (const r of tryRows) {
        const row = rowsMatrix[r] || [];
        const hasMonth = row.some((cell, i) => i >= 2 && typeof cell === 'string' && /thang\s*\d{1,2}|month\s*\d{1,2}/i.test(cell));
        if (hasMonth) { headerRow = r; break; }
      }
      const startRow = 5;  // data from row 6
      const nameCol = 1;   // column B: parameter names
      const unitCol = 2;   // column C: units per parameter
      const startCol = 3;  // column D onwards: values per month

      const monthsRow = rowsMatrix[headerRow] || [];
      // Map month columns
      const monthCols = [];
      const year = Number(req.body.year) || new Date().getFullYear();
      for (let c = startCol; c < monthsRow.length; c++) {
        const label = monthsRow[c];
        if (!label) continue;
        const mMatch = norm(label).match(/thang\s*(\d{1,2})|month\s*(\d{1,2})|(\d{1,2})$/);
        let m = null;
        if (mMatch) m = Number(mMatch[1] || mMatch[2] || mMatch[3]);
        if (m && m >= 1 && m <= 12) {
          const mm = String(m).padStart(2, '0');
          const createdAt = new Date(`${year}-${mm}-01T12:00:00Z`);
          monthCols.push({ col: c, createdAt });
        } else {
          monthCols.push({ col: c, createdAt: null });
        }
      }
      // Fallback: if header cells are merged/empty and detection failed, assume all columns from startCol are values
      if (!monthCols.length) {
        const widest = Math.max(monthsRow.length, ...(rowsMatrix.slice(startRow).map(r => (r || []).length)));
        for (let c = startCol; c < widest; c++) monthCols.push({ col: c, createdAt: null });
      }
      logger.info('[Excel] headerRow:', { headerRow: headerRow + 1, monthColsCount: monthCols.length });
      // Hard-code only 4 needed features by absolute row index:
      // Row numbers are 1-based visually; here we use 0-based indices.
      const rowIndexByFeature = {
        O2ml_L: 5,   // row 6: Ôxy hoà tan (DO)
        T_degC: 6,   // row 7: Nhiệt độ nước biển
        Salnty: 8,   // row 9: Độ mặn
        Dry_T: 13,   // row 14: Nhiệt độ không khí
      };
      const collected = monthCols.map(mc => ({ createdAt: mc.createdAt }));
      for (const [feat, r] of Object.entries(rowIndexByFeature)) {
        const row = rowsMatrix[r] || [];
        const unitText = row[unitCol] ? norm(row[unitCol]) : '';
        logger.info(`[Excel] row ${r + 1}: feat=${feat} unit='${unitText}' values@cols=${monthCols.map(m => m.col).join(',')}`);
        for (let i = 0; i < monthCols.length; i++) {
          const { col } = monthCols[i];
          const raw = row[col];
          let num = raw === '' || raw === null || raw === undefined ? null : Number(raw);
          if (feat === 'O2ml_L' && num != null) {
            if (/mg\s*\/\s*l/.test(unitText)) num = num / 1.429;
          }
          if (num !== null && !isNaN(num)) collected[i][feat] = num;
        }
      }
      normalized = collected.filter(o => Object.keys(o).some(k => k !== 'createdAt'));
      logger.info('[Excel] normalized count (fixed):', { count: normalized.length });
      if (normalized.length) logger.info('[Excel] normalized[0]:', normalized[0]);
    }
    if (!normalized.length) {
      return res.status(400).json({ error: 'Could not detect any usable indicators from Excel', debug: { rowsObjects: rowsObjects.length, rowsMatrix: rowsMatrix.length } });
    }

    // Reuse existing batch controller logic with parsed data
    logger.info('[Excel] Sending normalized data to batch:', { size: normalized.length });

    req.body = { userId, areaId, modelName, data: normalized };
    logger.debug('[Excel] Normalized data:', normalized);

    return exports.createBatchPrediction(req, res);
  } catch (error) {
    logger.error('createBatchPredictionFromExcel error:', error);
    return res.status(500).json({ error: error.message });
  }
};

// New: Excel2 template - rows start at row 4, first col is station name (merged over 4 quarter rows), col 3 is time "Quý X Năm YYYY"
// Header row is row 2 (index 1), modelName comes from request body
exports.createBatchPredictionFromExcel2 = async (req, res) => {
  try {
    if (!req.file || !req.file.buffer) return res.status(400).json({ error: 'Excel file is required (field name: file)' });
    const userId = req.user?.id || req.body.userId;
    const modelName = req.body.modelName; // Get modelName from request body
    if (!userId) return res.status(400).json({ error: 'userId is required (from token)' });
    if (!modelName) return res.status(400).json({ error: 'modelName is required' });

    logger.info('[Excel2] Processing with modelName:', { modelName, userId });
    const parsed = await parseExcel2(req.file.buffer);
    logger.info('[Excel2] Parsed rows:', { count: parsed.length });

    // Process rows sequentially (one by one) instead of parallel
    const results = [];
    let created = 0;

    for (let index = 0; index < parsed.length; index++) {
      const row = parsed[index];

      if (!row.areaId) {
        logger.warn(`[Excel2] Skipping row ${index + 1}/${parsed.length} without areaId:`, row.areaName);
        results.push({ success: false, skipped: true });
        continue;
      }

      try {
        const inputs = row.metrics;

        // Calculate createdAt from year and quarter if available
        let createdAt = null;
        if (row.year && row.quarter) {
          // Quarter 1 = Jan (month 0), Quarter 2 = Apr (month 3), etc.
          const month = (row.quarter - 1) * 3;
          createdAt = new Date(row.year, month, 1);
          logger.debug(`[Excel2] Using custom date for row ${index + 1}:`, {
            year: row.year,
            quarter: row.quarter,
            createdAt
          });
        }

        const result = await createPredictionInternal(
          userId,
          row.areaId,
          inputs,
          modelName,
          createdAt
        );

        logger.info(`[Excel2] Successfully created prediction for row ${index + 1}/${parsed.length}`, {
          areaName: row.areaName,
          predictionId: result.prediction_id
        });

        results.push({ success: true, data: result });
        created++;
      } catch (error) {
        logger.error(`[Excel2] Error processing row ${index + 1}/${parsed.length} (area: ${row.areaName}):`, {
          error: error.message,
          statusCode: error.statusCode,
          data: error.data
        });
        // Stop processing and let worker mark job as failed
        throw new Error(`Failed at row ${index + 1}/${parsed.length} (area: ${row.areaName}): ${error.message}`);
      }
    }

    logger.info('[Excel2] Created predictions:', { created, total: parsed.length });
    return res.json({ parsed: parsed.length, created });
  } catch (e) {
    logger.error('createBatchPredictionFromExcel2 error:', e);
    return res.status(500).json({ error: e.message });
  }
};

// Get prediction data for charts - latest and previous predictions with indicators
exports.getPredictionChartData = async (req, res) => {
  try {
    const { areaId, limit = 10 } = req.query;
    logger.info('Fetching prediction chart data for area:', { areaId });

    if (!areaId) {
      return res.status(400).json({ error: 'areaId is required' });
    }

    // Get latest predictions with nature elements for the specified area
    const predictions = await Prediction.findAll({
      where: { area_id: areaId },
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false, // Don't filter out predictions without nature elements
        },
        {
          model: Area,
          attributes: ['id', 'name', 'area_type'],
        },
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit, 10),
    });

    if (predictions.length === 0) {
      return res.status(404).json({
        error: 'No predictions found for this area',
        data: []
      });
    }

    // Get all unique nature elements to ensure consistent structure
    const allNatureElements = await NatureElement.findAll({
      attributes: ['id', 'name', 'description', 'unit', 'category'],
      order: [['name', 'ASC']]
    });

    // Format data for charts
    const chartData = predictions.map((prediction, index) => {
      const indicators = {};

      // Initialize all nature elements with null values
      allNatureElements.forEach(element => {
        indicators[element.name] = null;
      });

      // Fill in actual values from prediction
      prediction.NatureElements.forEach(natureElement => {
        indicators[natureElement.name] = natureElement.PredictionNatureElement.value;
      });

      return {
        id: prediction.id,
        prediction_text: prediction.prediction_text,
        date: prediction.createdAt,
        area: {
          id: prediction.Area.id,
          name: prediction.Area.name,
          area_type: prediction.Area.area_type
        },
        indicators: indicators,
        isLatest: index === 0, // Mark the first (latest) prediction
        timeAgo: getTimeAgo(prediction.createdAt)
      };
    });

    // Calculate trends for each indicator
    const trends = {};
    if (chartData.length > 1) {
      allNatureElements.forEach(element => {
        const latestValue = chartData[0].indicators[element.name];
        const previousValue = chartData[1].indicators[element.name];

        if (latestValue !== null && previousValue !== null) {
          const change = latestValue - previousValue;
          const changePercent = previousValue !== 0 ? (change / previousValue) * 100 : 0;

          trends[element.name] = {
            change: change,
            changePercent: changePercent,
            trend: change > 0 ? 'up' : change < 0 ? 'down' : 'stable'
          };
        }
      });
    }

    res.json({
      success: true,
      data: {
        predictions: chartData,
        trends: trends,
        summary: {
          totalPredictions: chartData.length,
          latestPredictionDate: chartData[0]?.date,
          area: chartData[0]?.area,
          indicators: allNatureElements.map(el => ({
            id: el.id,
            name: el.name,
            description: el.description,
            unit: el.unit,
            category: el.category
          }))
        }
      }
    });

  } catch (error) {
    logger.error('Get Prediction Chart Data Error:', {
      message: error.message,
      stack: error.stack,
      areaId: req.query.areaId,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get prediction data for charts - all areas with latest predictions
exports.getAllPredictionChartData = async (req, res) => {
  try {
    const { limit = 5 } = req.query;
    logger.info('Fetching all prediction chart data:', { limit });

    // Get latest predictions for all areas
    const predictions = await Prediction.findAll({
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false, // Don't filter out predictions without nature elements
        },
        {
          model: Area,
          attributes: ['id', 'name', 'area_type', 'province', 'district'],
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit, 10),
    });

    if (predictions.length === 0) {
      return res.status(404).json({
        error: 'No predictions found',
        data: []
      });
    }

    // Get all unique nature elements
    const allNatureElements = await NatureElement.findAll({
      attributes: ['id', 'name', 'description', 'unit', 'category'],
      order: [['name', 'ASC']]
    });

    // Group predictions by area
    const areaGroups = {};
    predictions.forEach(prediction => {
      const areaId = prediction.area_id;
      if (!areaGroups[areaId]) {
        areaGroups[areaId] = [];
      }
      areaGroups[areaId].push(prediction);
    });

    // Format data for charts
    const chartData = Object.keys(areaGroups).map(areaId => {
      const areaPredictions = areaGroups[areaId];
      const latestPrediction = areaPredictions[0]; // Most recent for this area

      const indicators = {};

      // Initialize all nature elements with null values
      allNatureElements.forEach(element => {
        indicators[element.name] = null;
      });

      // Fill in actual values from latest prediction
      latestPrediction.NatureElements.forEach(natureElement => {
        indicators[natureElement.name] = natureElement.PredictionNatureElement.value;
      });

      // Calculate trends if there are multiple predictions for this area
      const trends = {};
      if (areaPredictions.length > 1) {
        const previousPrediction = areaPredictions[1];
        allNatureElements.forEach(element => {
          const latestValue = indicators[element.name];
          const previousValue = previousPrediction.NatureElements.find(
            ne => ne.name === element.name
          )?.PredictionNatureElement?.value;

          if (latestValue !== null && previousValue !== null) {
            const change = latestValue - previousValue;
            const changePercent = previousValue !== 0 ? (change / previousValue) * 100 : 0;

            trends[element.name] = {
              change: change,
              changePercent: changePercent,
              trend: change > 0 ? 'up' : change < 0 ? 'down' : 'stable'
            };
          }
        });
      }

      return {
        area: {
          id: latestPrediction.Area.id,
          name: latestPrediction.Area.name,
          area_type: latestPrediction.Area.area_type,
          province: latestPrediction.Area.province,
          district: latestPrediction.Area.district,
          Province: latestPrediction.Area.Province,
          District: latestPrediction.Area.District
        },
        latestPrediction: {
          id: latestPrediction.id,
          prediction_text: latestPrediction.prediction_text,
          date: latestPrediction.createdAt,
          timeAgo: getTimeAgo(latestPrediction.createdAt)
        },
        indicators: indicators,
        trends: trends,
        totalPredictions: areaPredictions.length
      };
    });

    res.json({
      success: true,
      data: {
        areas: chartData,
        summary: {
          totalAreas: chartData.length,
          totalPredictions: predictions.length,
          indicators: allNatureElements.map(el => ({
            id: el.id,
            name: el.name,
            description: el.description,
            unit: el.unit,
            category: el.category
          }))
        }
      }
    });

  } catch (error) {
    logger.error('Get All Prediction Chart Data Error:', {
      message: error.message,
      stack: error.stack,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Stats for predictions: latest prediction ratio (good/average/poor) per area
exports.getLatestPredictionStats = async (req, res) => {
  try {
    const { role, province, district } = req.query;

    // Build area filter based on user role
    const areaWhere = {};
    if (role === 'manager') {
      if (district) {
        areaWhere.district = district;
      } else if (province) {
        areaWhere.province = province;
      }
    }

    // Reuse logic from getAllPredictionChartData but only need latest per area
    const predictions = await Prediction.findAll({
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false,
        },
        {
          model: Area,
          attributes: ['id', 'name', 'area_type', 'province', 'district'],
          where: Object.keys(areaWhere).length > 0 ? areaWhere : undefined,
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
      ],
      order: [['createdAt', 'DESC']],
    });
    logger.info(`Predictions haha: ${predictions.length}`);
    if (predictions.length === 0) {
      return res.status(200).json({
        good: 0,
        average: 0,
        poor: 0,
        totalAreas: 0,
      });
    }

    // Group by area and get latest prediction for each area
    const areaGroups = {};
    predictions.forEach(prediction => {
      const areaId = prediction.area_id;
      if (!areaGroups[areaId]) {
        areaGroups[areaId] = prediction; // Store only the latest (first one due to DESC order)
      }
    });

    let good = 0;
    let average = 0;
    let poor = 0;

    Object.values(areaGroups).forEach(prediction => {
      const value = parseInt(prediction.prediction_text, 10);
      if (value === 1) good += 1;
      else if (value === 0) average += 1;
      else if (value === -1) poor += 1;
    });

    return res.status(200).json({
      good,
      average,
      poor,
      totalAreas: Object.keys(areaGroups).length,
    });
  } catch (error) {
    logger.error('Get Latest Prediction Stats Error:', {
      message: error.message,
      stack: error.stack,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// Helper function to calculate time ago
function getTimeAgo(date) {
  const now = new Date();
  const diffInSeconds = Math.floor((now - new Date(date)) / 1000);

  if (diffInSeconds < 60) {
    return `${diffInSeconds} giây trước`;
  } else if (diffInSeconds < 3600) {
    const minutes = Math.floor(diffInSeconds / 60);
    return `${minutes} phút trước`;
  } else if (diffInSeconds < 86400) {
    const hours = Math.floor(diffInSeconds / 3600);
    return `${hours} giờ trước`;
  } else {
    const days = Math.floor(diffInSeconds / 86400);
    return `${days} ngày trước`;
  }
}

// Export predictions to Excel with filters
exports.exportPredictionsToExcel = async (req, res) => {
  try {
    const ExcelJS = require('exceljs');
    logger.info('Starting Excel export', { query: req.query });

    // Check user role
    if (req.user.role !== 'admin' && req.user.role !== 'manager') {
      return res.status(403).json({ error: 'Access denied. Admins and managers only.' });
    }

    const {
      userId = undefined,
      areaId = undefined,
      predictionResult = undefined, // -1, 0, 1
      areaType = undefined, // oyster, cobia
      province = undefined,
      district = undefined,
      startDate = undefined,
      endDate = undefined,
    } = req.query;

    // Build query options
    const options = {
      attributes: ['id', 'user_id', 'area_id', 'prediction_text', 'createdAt', 'updatedAt'],
      include: [
        {
          model: User,
          attributes: ['id', 'username', 'email', 'role'],
        },
        {
          model: Area,
          attributes: [
            'id',
            'name',
            'latitude',
            'longitude',
            'area',
            'area_type',
            'province',
            'district',
          ],
          include: [
            {
              model: Province,
              attributes: ['id', 'name'],
            },
            {
              model: District,
              attributes: ['id', 'name'],
            },
          ],
        },
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
          required: false,
        },
      ],
      order: [['createdAt', 'DESC']],
    };

    const where = {};
    
    // Filter by userId
    if (userId) where.user_id = parseInt(userId, 10);
    
    // Filter by areaId
    if (areaId) where.area_id = parseInt(areaId, 10);
    
    // Filter by prediction result
    if (predictionResult !== undefined && predictionResult !== '') {
      where.prediction_text = parseInt(predictionResult, 10);
    }
    
    // Filter by date range
    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) {
        where.createdAt[Op.gte] = new Date(startDate);
      }
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.createdAt[Op.lte] = end;
      }
    }

    // Filter by area type
    if (areaType) {
      where['$Area.area_type$'] = areaType;
      options.include[1].required = true;
    }

    // Filter by province/district
    if (province) {
      where['$Area.province$'] = province;
      options.include[1].required = true;
    }
    if (district) {
      where['$Area.district$'] = district;
      options.include[1].required = true;
    }

    // Manager role restrictions
    if (req.user.role === 'manager') {
      const userProvince = req.user.province;
      const userDistrict = req.user.district;

      if (userDistrict) {
        where['$Area.district$'] = userDistrict;
        options.include[1].required = true;
      } else if (userProvince) {
        where['$Area.province$'] = userProvince;
        options.include[1].required = true;
      } else {
        return res.status(403).json({
          error: 'Manager must be assigned to a province or district.',
        });
      }
    }

    options.where = where;

    // Fetch all predictions (no limit/offset for export)
    const predictions = await Prediction.findAll(options);

    if (!predictions || predictions.length === 0) {
      logger.warn('[Excel Export] No predictions found with filters', { query: req.query });
      return res.status(404).json({ error: 'No predictions found with the specified filters' });
    }

    logger.info(`[Excel Export] Found ${predictions.length} predictions for export`, { 
      filters: { areaId, predictionResult, areaType, province, district, startDate, endDate }
    });

    // Create Excel workbook
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Environment Prediction System';
    workbook.created = new Date();
    
    // Sheet 1: Detailed Report
    const worksheet = workbook.addWorksheet('Báo cáo dự đoán', {
      views: [{ state: 'frozen', xSplit: 0, ySplit: 1 }]
    });

    // Define columns
    const columns = [
      { header: 'STT', key: 'stt', width: 8 },
      { header: 'Mã dự đoán', key: 'id', width: 12 },
      { header: 'Ngày tạo', key: 'createdAt', width: 20 },
      { header: 'Quý', key: 'quarter', width: 10 },
      { header: 'Tháng', key: 'month', width: 10 },
      { header: 'Tên khu vực', key: 'areaName', width: 25 },
      { header: 'Loại khu vực', key: 'areaType', width: 15 },
      { header: 'Tỉnh/Thành phố', key: 'province', width: 20 },
      { header: 'Quận/Huyện', key: 'district', width: 20 },
      { header: 'Diện tích (ha)', key: 'areaSize', width: 15 },
      { header: 'Vĩ độ', key: 'latitude', width: 12 },
      { header: 'Kinh độ', key: 'longitude', width: 12 },
      { header: 'Kết quả số', key: 'predictionValue', width: 12 },
      { header: 'Đánh giá', key: 'predictionText', width: 15 },
      { header: 'Tên người dùng', key: 'username', width: 18 },
      { header: 'Email', key: 'email', width: 25 },
      { header: 'Vai trò', key: 'role', width: 12 },
    ];

    // Add environment indicator columns
    const indicators = ['R_PO4', 'O2Sat', 'O2ml_L', 'STheta', 'Salnty', 'R_DYNHT', 'T_degC', 
                       'R_Depth', 'Distance', 'Wind_Spd', 'Wave_Ht', 'Wave_Prd', 'IntChl', 'Dry_T'];
    
    indicators.forEach(indicator => {
      columns.push({
        header: indicator,
        key: indicator,
        width: 12
      });
    });

    worksheet.columns = columns;

    // Style header row
    const headerRow = worksheet.getRow(1);
    headerRow.height = 25;
    headerRow.font = { bold: true, size: 11, color: { argb: 'FFFFFFFF' } };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF1F4E78' }
    };
    headerRow.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
    headerRow.border = {
      top: { style: 'thin' },
      left: { style: 'thin' },
      bottom: { style: 'thin' },
      right: { style: 'thin' }
    };

    // Add data rows with comprehensive error handling
    let successfulRows = 0;
    let failedRows = 0;
    
    predictions.forEach((prediction, index) => {
      try {
        // Safely handle date with fallback
        const date = prediction.createdAt ? new Date(prediction.createdAt) : null;
        const quarter = date ? Math.ceil((date.getMonth() + 1) / 3) : 0;
        const month = date ? date.getMonth() + 1 : 0;

        // Map prediction value to text with proper handling
        let predictionText = 'Không xác định';
        let predictionColor = 'FFFFFF00'; // Yellow
        
        // Safely parse prediction_text
        const predValue = prediction.prediction_text !== null && prediction.prediction_text !== undefined 
          ? parseInt(prediction.prediction_text, 10) 
          : NaN;
        
        if (!isNaN(predValue)) {
          if (predValue === 1) {
            predictionText = 'Tốt';
            predictionColor = 'FF52C41A'; // Green
          } else if (predValue === 0) {
            predictionText = 'Trung bình';
            predictionColor = 'FFFAAD14'; // Orange
          } else if (predValue === -1) {
            predictionText = 'Kém';
            predictionColor = 'FFFF4D4F'; // Red
          }
        }

        const rowData = {
          stt: index + 1,
          id: prediction.id || '-',
          createdAt: prediction.createdAt ? date.toLocaleString('vi-VN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
          }) : '-',
          quarter: prediction.createdAt ? `Quý ${quarter}` : '-',
          month: prediction.createdAt ? `Tháng ${month}` : '-',
          areaName: prediction.Area?.name || '-',
          // Use snake_case area_type from database
          areaType: prediction.Area?.area_type === 'oyster' ? 'Hàu' : prediction.Area?.area_type === 'cobia' ? 'Cá bớp' : '-',
          province: prediction.Area?.Province?.name || '-',
          district: prediction.Area?.District?.name || '-',
          areaSize: (prediction.Area?.area !== null && prediction.Area?.area !== undefined) ? prediction.Area.area : '-',
          latitude: (prediction.Area?.latitude !== null && prediction.Area?.latitude !== undefined) ? prediction.Area.latitude : '-',
          longitude: (prediction.Area?.longitude !== null && prediction.Area?.longitude !== undefined) ? prediction.Area.longitude : '-',
          // Use snake_case prediction_text from database
          predictionValue: !isNaN(predValue) ? predValue : '-',
          predictionText: predictionText,
          username: prediction.User?.username || '-',
          email: prediction.User?.email || '-',
          role: prediction.User?.role || '-',
        };

        // Add indicator values with proper fallback handling
        indicators.forEach(indicator => {
          try {
            const element = prediction.NatureElements?.find(ne => ne.name === indicator);
            const value = element?.PredictionNatureElement?.value;
            // Keep 0 as valid value, only fallback for null/undefined
            rowData[indicator] = (value !== null && value !== undefined) ? value : '-';
          } catch (err) {
            logger.warn(`[Excel Export] Error processing indicator ${indicator} for prediction ${prediction.id}:`, err.message);
            rowData[indicator] = '-';
          }
        });

        const row = worksheet.addRow(rowData);
        
        // Style prediction result cell with color
        const predictionTextCell = row.getCell('predictionText');
        predictionTextCell.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: predictionColor }
        };
        predictionTextCell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
        predictionTextCell.alignment = { horizontal: 'center', vertical: 'middle' };

        // Apply borders to all cells
        row.eachCell({ includeEmpty: true }, (cell) => {
          cell.border = {
            top: { style: 'thin', color: { argb: 'FFD0D0D0' } },
            left: { style: 'thin', color: { argb: 'FFD0D0D0' } },
            bottom: { style: 'thin', color: { argb: 'FFD0D0D0' } },
            right: { style: 'thin', color: { argb: 'FFD0D0D0' } }
          };
          cell.alignment = { vertical: 'middle' };
        });
        
        successfulRows++;
      } catch (rowError) {
        failedRows++;
        logger.error(`[Excel Export] Error processing prediction row ${index + 1} (ID: ${prediction?.id}):`, {
          error: rowError.message,
          stack: rowError.stack
        });
        // Continue with next row instead of breaking the entire export
      }
    });
    
    logger.info(`[Excel Export] Processed rows: ${successfulRows} successful, ${failedRows} failed`);

    // Sheet 2: Summary Statistics
    const summarySheet = workbook.addWorksheet('Thống kê tổng hợp');
    
    summarySheet.mergeCells('A1:B1');
    const titleCell = summarySheet.getCell('A1');
    titleCell.value = 'THỐNG KÊ TỔNG HỢP DỰ ĐOÁN';
    titleCell.font = { bold: true, size: 16, color: { argb: 'FF1F4E78' } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
    summarySheet.getRow(1).height = 30;

    // Statistics data
    const totalPredictions = predictions.length;
    const goodCount = predictions.filter(p => parseInt(p.prediction_text) === 1).length;
    const averageCount = predictions.filter(p => parseInt(p.prediction_text) === 0).length;
    const poorCount = predictions.filter(p => parseInt(p.prediction_text) === -1).length;

    const statsData = [
      ['', ''],
      ['Tổng số dự đoán', totalPredictions],
      ['Số dự đoán Tốt', goodCount],
      ['Số dự đoán Trung bình', averageCount],
      ['Số dự đoán Kém', poorCount],
      ['', ''],
      ['Tỷ lệ Tốt (%)', totalPredictions > 0 ? ((goodCount / totalPredictions) * 100).toFixed(2) : 0],
      ['Tỷ lệ Trung bình (%)', totalPredictions > 0 ? ((averageCount / totalPredictions) * 100).toFixed(2) : 0],
      ['Tỷ lệ Kém (%)', totalPredictions > 0 ? ((poorCount / totalPredictions) * 100).toFixed(2) : 0],
    ];

    statsData.forEach((row, index) => {
      const excelRow = summarySheet.addRow(row);
      if (index > 0 && row[0]) {
        excelRow.getCell(1).font = { bold: true };
        excelRow.getCell(1).fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FFF0F0F0' }
        };
      }
    });

    summarySheet.getColumn(1).width = 25;
    summarySheet.getColumn(2).width = 20;

    // Sheet 3: Notes
    const notesSheet = workbook.addWorksheet('Ghi chú');
    
    notesSheet.mergeCells('A1:B1');
    const notesTitleCell = notesSheet.getCell('A1');
    notesTitleCell.value = 'GIẢI THÍCH CÁC CHỈ SỐ MÔI TRƯỜNG';
    notesTitleCell.font = { bold: true, size: 14, color: { argb: 'FF1F4E78' } };
    notesTitleCell.alignment = { horizontal: 'center', vertical: 'middle' };
    notesSheet.getRow(1).height = 25;

    const indicatorNotes = [
      ['', ''],
      ['Chỉ số', 'Mô tả'],
      ['R_PO4', 'Phosphate (µmol/L)'],
      ['O2Sat', 'Độ bão hòa oxy (%)'],
      ['O2ml_L', 'Oxy hoà tan (ml/L)'],
      ['STheta', 'Mật độ tiềm năng nước biển (kg/m³)'],
      ['Salnty', 'Độ mặn (PSU)'],
      ['R_DYNHT', 'Độ cao động lực (m)'],
      ['T_degC', 'Nhiệt độ nước biển (°C)'],
      ['R_Depth', 'Độ sâu (m)'],
      ['Distance', 'Khoảng cách (km)'],
      ['Wind_Spd', 'Tốc độ gió (m/s)'],
      ['Wave_Ht', 'Chiều cao sóng (m)'],
      ['Wave_Prd', 'Chu kỳ sóng (s)'],
      ['IntChl', 'Chlorophyll tích hợp (mg/m²)'],
      ['Dry_T', 'Nhiệt độ không khí (°C)'],
    ];

    indicatorNotes.forEach((row, index) => {
      const excelRow = notesSheet.addRow(row);
      if (index === 2) {
        excelRow.font = { bold: true };
        excelRow.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FF1F4E78' }
        };
        excelRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      }
    });

    notesSheet.getColumn(1).width = 20;
    notesSheet.getColumn(2).width = 40;

    // Generate filename
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
    const filename = `BaoCaoDuDoan_${timestamp}.xlsx`;

    // Set response headers
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    // Write to response
    await workbook.xlsx.write(res);
    
    logger.info('Excel export completed successfully', { 
      filename, 
      recordCount: predictions.length,
      user: req.user.username 
    });

  } catch (error) {
    logger.error('Export Predictions to Excel Error:', {
      message: error.message,
      stack: error.stack,
      query: req.query,
    });
    res.status(500).json({ error: 'Internal server error while exporting Excel' });
  }
};