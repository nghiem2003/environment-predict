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
const pLimit = require('p-limit');

// Required fields for prediction model - only these should be saved to database
const REQUIRED_FIELDS = [
  'R_PO4', 'O2Sat', 'O2ml_L', 'STheta', 'Salnty', 'R_DYNHT', 'T_degC',
  'R_Depth', 'Distance', 'Wind_Spd', 'Wave_Ht', 'Wave_Prd', 'IntChl', 'Dry_T'
];

exports.createPrediction = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const { areaId, inputs, modelName } = req.body;

    const area = await Area.findByPk(areaId);
    logger.debug('modelName', { modelName });

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
    logger.debug(`[Prediction] Filtered inputs (${Object.keys(filteredInputs).length} fields)`, filteredInputs);

    // Prepare request data for Flask API - only include REQUIRED_FIELDS + lat/lon
    const flaskRequestData = {};
    REQUIRED_FIELDS.forEach(field => {
      if (filteredInputs[field] != null) {
        flaskRequestData[field] = filteredInputs[field];
      }
    });
    flaskRequestData.lat = area.latitude;
    flaskRequestData.lon = area.longitude;
    logger.debug('[Prediction] Flask request data (REQUIRED_FIELDS + lat/lon)', flaskRequestData);

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
      return res.status(axiosError.response?.status || 500).json({
        error: axiosError.response?.data?.error || axiosError.message || 'Flask API error'
      });
    }

    // Check HTTP status code
    if (flaskResponse.status >= 400) {
      logger.error('[Prediction] Flask returned error status', { status: flaskResponse.status, data: flaskResponse.data });
      return res.status(flaskResponse.status).json({
        error: flaskResponse.data?.error || 'Flask API returned error status'
      });
    }

    const flaskResult = flaskResponse.data;
    if (flaskResult.error) {
      logger.error('[Prediction] Flask response contains error', { error: flaskResult.error });
      return res.status(400).json({ error: flaskResult.error });
    }

    const { prediction_result } = flaskResult;

    const predictionRecord = await Prediction.create({
      user_id: userId,
      area_id: areaId,
      prediction_text: prediction_result.prediction,
      ...(req.body.createdAt && {
        createdAt: req.body.createdAt,
        updatedAt: req.body.createdAt,
      }),
    });

    // Save filtered inputs (already filtered above)
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
    }
    logger.info(`[Prediction] Saved ${Object.keys(filteredInputs).length} nature elements to database`);
    logger.info('Prediction created successfully', { predictionId: predictionRecord.id });

    // Send email notification to subscribers
    try {
      await sendPredictionNotification(areaId, {
        result: prediction_result.prediction,
        model: modelName,
        predictionId: predictionRecord.id,
      });
    } catch (emailError) {
      logger.error('Failed to send prediction notification', { error: emailError.message });
    }

    res.json({
      prediction_id: predictionRecord.id,
      prediction_text: prediction_result.prediction,
      model_used: modelName,
    });
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
      return res.status(404).json({ error: 'No predictions found' });

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
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const where = {};
    if (userId) where.user_id = userId;
    if (areaId) where.area_id = areaId;

    // Nếu là manager, chỉ cho phép xem dự đoán trong phạm vi quản lý
    if (req.user.role === 'manager') {
      const userProvince = req.user.province;
      const userDistrict = req.user.district;

      if (userDistrict) {
        // Manager cấp quận - chỉ xem dự đoán của quận đó
        where['$Area.district$'] = userDistrict;
      } else if (userProvince) {
        // Manager cấp tỉnh - xem dự đoán của tỉnh đó
        where['$Area.province$'] = userProvince;
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
    const { limit = 10, offset = 0 } = req.query;

    logger.debug('Fetching predictions for user', { userId, pagination: { limit, offset } });

    const options = {
      where: { user_id: userId },
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
          ],
        },
      ],
      order: [['createdAt', 'DESC']],
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const predictions = await Prediction.findAll(options);

    if (predictions.length === 0) {
      logger.debug('No predictions found for user', { userId });
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
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
    logger.log('[Excel] sheetName:', sheetName);
    logger.log('[Excel] rowsObjects length:', rowsObjects.length);
    logger.log('[Excel] rowsMatrix dims:', rowsMatrix.length, rowsMatrix[0] ? rowsMatrix[0].length : 0);
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
        logger.log('[Excel] Wide header map -> feature:', headerMap);
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
      logger.log('[Excel] headerRow:', headerRow + 1, '| monthCols parsed:', monthCols);
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
        logger.log(`[Excel] row ${r + 1}: feat=${feat} unit='${unitText}' values@cols=${monthCols.map(m => m.col).join(',')}`);
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
      logger.log('[Excel] normalized count (fixed):', normalized.length);
      if (normalized.length) logger.log('[Excel] normalized[0]:', normalized[0]);
    }
    if (!normalized.length) {
      return res.status(400).json({ error: 'Could not detect any usable indicators from Excel', debug: { rowsObjects: rowsObjects.length, rowsMatrix: rowsMatrix.length } });
    }

    // Reuse existing batch controller logic with parsed data
    logger.log('[Excel] Sending normalized data to batch, size=', normalized.length);

    req.body = { userId, areaId, modelName, data: normalized };
    logger.log(normalized);

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

    logger.log('[Excel2] Processing with modelName:', modelName, 'userId:', userId);
    const parsed = await parseExcel2(req.file.buffer);
    logger.log('[Excel2] Parsed rows:', parsed.length);

    // Create p-limit instance with concurrency of 5
    const limit = pLimit(5);

    // Process rows with concurrent limit of 5
    const processRow = async (row, index) => {
      if (!row.areaId) {
        logger.warn(`[Excel2] Skipping row ${index + 1}/${parsed.length} without areaId:`, row.areaName);
        return { success: false, skipped: true };
      }

      const inputs = row.metrics;
      const fakeReq = { body: { userId, areaId: row.areaId, inputs, modelName } };

      return new Promise((resolve, reject) => {
        let statusCode = 200;
        let resolved = false;
        const r = {
          status(c) {
            statusCode = c;
            return this;
          },
          json(data) {
            if (resolved) return; // Prevent multiple resolves
            resolved = true;
            // Check status code and reject if error
            if (statusCode >= 400) {
              const error = new Error(data?.error || `createPrediction returned status ${statusCode}`);
              error.statusCode = statusCode;
              error.data = data;
              reject(error);
            } else {
              resolve({ success: true, status: statusCode, data });
            }
          }
        };
        Promise.resolve(exports.createPrediction(fakeReq, r))
          .catch(error => {
            if (!resolved) {
              resolved = true;
              reject(error);
            }
          });
      });
    };

    // Create array of promises with p-limit
    const promises = parsed.map((row, index) =>
      limit(() => processRow(row, index).catch(error => {
        logger.error(`[Excel2] Error processing row ${index + 1}/${parsed.length} (area: ${row.areaName}):`, {
          error: error.message,
          statusCode: error.statusCode,
          data: error.data
        });
        // Re-throw to stop processing and let worker mark job as failed
        throw new Error(`Failed at row ${index + 1}/${parsed.length} (area: ${row.areaName}): ${error.message}`);
      }))
    );

    // Wait for all promises to complete
    const results = await Promise.all(promises);
    const created = results.filter(r => r && r.success && !r.skipped).length;

    logger.log('[Excel2] Created predictions:', created, 'out of', parsed.length, 'parsed rows');
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
    logger.log('Fetching prediction chart data for area:', areaId);

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
    logger.log('Fetching all prediction chart data with limit:', limit);

    // Get latest predictions for all areas
    const predictions = await Prediction.findAll({
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name', 'description', 'unit', 'category'],
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