const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Region = sequelize.define(
  'Region',
  {
    id: { type: DataTypes.UUID, defaultValue:DataTypes.UUIDV4, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    province: { type: DataTypes.STRING, allowNull: false },
  },
  { timestamps: false, tableName: 'regions' }
);

module.exports = Region;
