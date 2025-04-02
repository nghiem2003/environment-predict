const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Area = sequelize.define(
  'Area',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    address: { type: DataTypes.STRING, allowNull: false },
    latitude: { type: DataTypes.DOUBLE, allowNull: false },
    longitude: { type: DataTypes.DOUBLE, allowNull: false },
    area: { type: DataTypes.DOUBLE, allowNull: false },
    area_type: { type: DataTypes.ENUM('oyster', 'cobia'), allowNull: false },
  },
  { timestamps: false, tableName: 'diagnose_areas' }
);

module.exports = Area;
