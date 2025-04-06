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
    console.log(req.body);

    const endpoint = modelName.includes('oyster')
      ? '/predict/oyster'
      : '/predict/cobia';
    const flaskUrl = `${process.env.FLASK_API_URL}${endpoint}`;
    const flaskResponse = await axios.post(flaskUrl, inputs, {
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
      ...(req.body.createdAt && { createdAt: req.body.createdAt, updatedAt: req.body.createdAt }),
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
    console.log('done added');

    res.json({
      prediction_id: predictionRecord.id,
      prediction_text: prediction,
      model_used: modelName,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getLatestPrediction = async (req, res) => {
  try {
    const { areaId } = req.params;

    // Find the latest prediction for the area
    const prediction = await Prediction.findOne({
      where: { area_id: areaId },
      order: [['id', 'DESC']],
      include: [
        {
          model: NatureElement,
          through: {
            attributes: ['value'], // Include the value of each nature element
          },
        },
      ],
    });

    if (!prediction)
      return res.status(404).json({ error: 'No predictions found' });

    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPredictionDetails = async (req, res) => {
  try {
    const { predictionId } = req.params;
    // Fetch prediction by ID with associated area and natural elements
    const prediction = await Prediction.findOne({
      where: { id: predictionId },
      include: [
        {
          model: Area,
          as: 'Area',
          attributes: [
            'id',
            'name',
            'address',
            'latitude',
            'longitude',
            'area',
            'area_type',
          ], // Area details
        },
        {
          model: NatureElement,
          through: {
            attributes: ['value'], // Include value from the join table
          },
          attributes: ['id', 'name'], // Natural element details
        },
      ],
    });

    if (!prediction) {
      return res.status(404).json({ error: 'Prediction not found' });
    }

    res.json(prediction);
  } catch (error) {
    //console.error('Error fetching prediction details:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllPredictionsWithFilters = async (req, res) => {
  try {
    // Ensure the user is an admin
    console.log('Doing fetch');
    
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied. Admins only.' });
    }

    // Safely destructure query parameters with defaults
    const {
      userId = undefined,
      areaId = undefined,
      limit = 10,
      offset = 0,
    } = req.query;

    // Build the where clause dynamically
    const where = {};
    if (userId) where.user_id = userId;
    if (areaId) where.area_id = areaId;

    // Fetch predictions with filters, pagination, and includes
    const predictions = await Prediction.findAndCountAll({
      //where,
      include: [
          {
          model: User,
          attributes: ['id','username', 'email', 'role'], // Include user details
        },
        {
          model: Area,
          attributes: [
            'id',
            'name',
            'address',
            'latitude',
            'longitude',
            'area',
            'area_type',
          ], // Include area details
        },
      ],
      order: [['id', 'DESC']], // Sort by most recent predictions
    });

     if (predictions.length === 0) {
      console.log('no record found');
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
    }
    res.json(predictions);
  } catch (error) {
    console.error('Error fetching predictions with filters:', error.message);
    console.log('eror:',error);
    
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getPredictionsByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch predictions made by the user
    const predictions = await Prediction.findAll({
      where: { user_id: userId },
      include: [
        {
          model: Area,
          as: 'Area',
          attributes: [
            'id',
            'name',
            'address',
            'latitude',
            'longitude',
            'area',
            'area_type',
          ], // Area details
        },
      ],
      order: [['id', 'DESC']], // Sort predictions by most recent
    });

    if (predictions.length === 0) {
      console.log('no record found');
      return res
        .status(404)
        .json({ error: 'No predictions found for this user' });
    }
    res.json(predictions);
  } catch (error) {
    console.error('Error fetching predictions by user:', error.message);
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
      const {createdAt, ...natureElements} = inputs
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
      const entry = await NatureElement.findOne({
        where: { name: elementName },
      });

      await PredictionNatureElement.create({
        prediction_id: predictionRecord.id,
        nature_element_id: entry.id,
        value,
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
    res.status(500).json({ error: error.message });
  }
};
