const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Province = sequelize.define(
  'Province',
  {
    id: { type: DataTypes.UUID, defaultValue:DataTypes.UUIDV4, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
  },
  { timestamps: false, tableName: 'provinces' }
);

module.exports = Province;
