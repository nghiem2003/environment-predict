const Sequelize = require('sequelize');
const sequelize = require('../config/db');

// Import models
const User = require('./User');
const Area = require('./Area');
const Prediction = require('./Prediction');
const NatureElement = require('./NatureElement');
const PredictionNatureElement = require('./PredictionNatureElement');
const Region = require('./Region');

// Initialize models
const models = {
  User,
  Area,
  Prediction,
  NatureElement,
  PredictionNatureElement,
  Region
};

// Dynamically associate models after all are initialized
Object.values(models).forEach((model) => {
  if (model.associate) {
    model.associate(models);
  }
});

module.exports = {
  ...models,
  sequelize,
};
