const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define(
  'Users',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    username: { type: DataTypes.STRING, unique: true, allowNull: false },
    password: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, unique: true, allowNull: false },
    address: { type: DataTypes.STRING, allowNull: true },
    phone: { type: DataTypes.STRING, allowNull: true },
    role: {
      type: DataTypes.ENUM('expert', 'admin'),
      allowNull: false,
    },
  },
  { timestamps: false, tableName: 'users' }
);

module.exports = User;
