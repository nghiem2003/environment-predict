const { Sequelize } = require('sequelize');
require('dotenv').config();

const { DB_HOST, DB_USER, DB_PASSWORD, DB_NAME } = process.env;

// Create a Sequelize instance for the PostgreSQL database
const sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASSWORD, {
  host: DB_HOST, // e.g., 'localhost'
  dialect: 'postgres', // Use PostgreSQL
  logging: false, // Disable logging (optional)
  port: 5432,
});

module.exports = sequelize;
