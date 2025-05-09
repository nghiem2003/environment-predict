const {
  Prediction,
  PredictionNatureElement,
  NatureElement,
  Area,
  User,
} = require('../models');
const { Op } = require('sequelize');
require('dotenv').config();
const axios = require('axios');

exports.createPrediction = async (req, res) => {
  try {
    const { userId, areaId, inputs, modelName } = req.body;
    console.log('Creating prediction with data:', req.body);

    const parsedInputs = inputs.map((input) => Number.parseFloat(input));
    console.log('parsedInputs:', parsedInputs);
    const endpoint = modelName.includes('oyster')
      ? '/predict/oyster'
      : '/predict/cobia';
    const flaskUrl = `${process.env.FLASK_API_URL}${endpoint}`;
    const flaskResponse = await axios.post(flaskUrl, parsedInputs, {
      params: { model: modelName },
    });

    const flaskResult = flaskResponse.data;
    if (flaskResult.error)
      return res.status(400).json({ error: flaskResult.error });

    const { prediction } = flaskResult;

    const predictionRecord = await Prediction.create({
      user_id: userId,
      area_id: areaId,
      prediction_text: prediction,
      ...(req.body.createdAt && {
        createdAt: req.body.createdAt,
        updatedAt: req.body.createdAt,
      }),
    });

    for (const [elementName, value] of Object.entries(inputs)) {
      const entry = await NatureElement.findOne({
        where: { name: elementName },
      });

      await PredictionNatureElement.create({
        prediction_id: predictionRecord.id,
        nature_element_id: entry.id,
        value,
      });
    }
    console.log('Prediction created successfully:', predictionRecord.id);

    res.json({
      prediction_id: predictionRecord.id,
      prediction_text: prediction,
      model_used: modelName,
    });
  } catch (error) {
    console.error('Create Prediction Error:', {
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
    console.log('Fetching latest prediction for area:', areaId);

    const prediction = await Prediction.findOne({
      where: { area_id: areaId },
      order: [['id', 'DESC']],
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
        },
      ],
    });

    if (!prediction)
      return res.status(404).json({ error: 'No predictions found' });

    res.json(prediction);
  } catch (error) {
    console.error('Get Latest Prediction Error:', {
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
    console.log('Fetching prediction details for ID:', predictionId);

    const prediction = await Prediction.findOne({
      where: { id: predictionId },
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
            'region',
            'area_type',
          ],
        },
        {
          model: NatureElement,
          through: {
            attributes: ['value'],
          },
          attributes: ['id', 'name'],
        },
      ],
    });

    if (!prediction) {
      return res.status(404).json({ error: 'Prediction not found' });
    }

    res.json(prediction);
  } catch (error) {
    console.error('Get Prediction Details Error:', {
      message: error.message,
      stack: error.stack,
      predictionId: req.params.predictionId,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllPredictionsWithFilters = async (req, res) => {
  try {
    console.log('Fetching all predictions with filters:', req.query);

    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied. Admins only.' });
    }

    const {
      userId = undefined,
      areaId = undefined,
      limit = 10,
      offset = 0,
    } = req.query;

    const options = {
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
      order: [['id', 'DESC']],
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

    const predictions = await Prediction.findAndCountAll(options);

    if (predictions.length === 0) {
      console.log('No predictions found with filters:', req.query);
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
    }
    res.json(predictions);
  } catch (error) {
    console.error('Get All Predictions With Filters Error:', {
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

    console.log('Fetching predictions for user:', userId, 'with pagination:', {
      limit,
      offset,
    });

    const options = {
      where: { user_id: userId },
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
      order: [['id', 'DESC']],
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const predictions = await Prediction.findAll(options);

    if (predictions.length === 0) {
      console.log('No predictions found for user:', userId);
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
    }
    res.json(predictions);
  } catch (error) {
    console.error('Get Predictions By User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.userId,
      pagination: req.query,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.createBatchPrediction = async (req, res) => {
  console.log('Batch Processing');

  const { userId, areaId, modelName, data } = req.body;
  try {
    const endpoint = modelName.includes('oyster')
      ? '/predict/oyster'
      : '/predict/cobia';
    const flaskUrl = `${process.env.FLASK_API_URL}${endpoint}`;

    const predictionsResult = [];

    for (const inputs of data) {
      const { createdAt, ...natureElements } = inputs;
      const flaskResponse = await axios.post(flaskUrl, natureElements, {
        params: { model: modelName },
      });
      const { prediction } = flaskResponse.data;

      const predictionRecord = await Prediction.create({
        user_id: userId,
        area_id: areaId,
        prediction_text: prediction,
        ...(createdAt && { createdAt: createdAt, updatedAt: createdAt }),
      });
      for (const [elementName, value] of Object.entries(inputs)) {
        if (elementName === 'createdAt') continue;
        console.log(elementName);
        console.log(value);

        const entry = await NatureElement.findOne({
          where: { name: elementName },
        });
        console.log(JSON.stringify(entry));

        await PredictionNatureElement.create({
          prediction_id: predictionRecord.id,
          nature_element_id: entry.id,
          value: value,
        });
      }
      console.log('done added');

      predictionsResult.push({
        prediction_id: predictionRecord.id,
        prediction_text: prediction,
        inputs,
      });
    }

    res.json({ predictions: predictionsResult, model_used: modelName });
  } catch (error) {
    console.log(error);

    res.status(500).json({ error: error.message });
  }
};
