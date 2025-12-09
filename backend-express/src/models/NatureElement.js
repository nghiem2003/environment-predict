const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const NaturalElement = sequelize.define(
  'NaturalElement',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    unit: { type: DataTypes.STRING, allowNull: true },
    category: { type: DataTypes.STRING, allowNull: true },
  },
  { timestamps: false, tableName: 'diagnose_naturalelements' }
);

NaturalElement.associate = (models) => {
  NaturalElement.belongsToMany(models.Prediction, {
    through: models.PredictionNatureElement,
    foreignKey: 'nature_element_id',
    otherKey: 'prediction_id',
  });
};

module.exports = NaturalElement;
