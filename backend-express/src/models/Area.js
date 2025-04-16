const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Area = sequelize.define(
  'Area',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    name: { type: DataTypes.STRING, allowNull: false },
    latitude: { type: DataTypes.DOUBLE, allowNull: false },
    longitude: { type: DataTypes.DOUBLE, allowNull: false },
    area: { type: DataTypes.DOUBLE, allowNull: false },
    region: { type: DataTypes.UUID, allowNull: true },
    area_type: { type: DataTypes.ENUM('oyster', 'cobia'), allowNull: false },
  },
  { timestamps: false, tableName: 'diagnose_areas' }
);

Area.associate = (models) => {
  console.log(models);
  
  Area.belongsTo(models.Region, {
    foreignKey: 'region',
    targetKey: 'id',
  });
}

module.exports = Area;
