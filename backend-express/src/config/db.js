const { Sequelize } = require('sequelize');

// Create a Sequelize instance for the PostgreSQL database
const sequelize = new Sequelize('ocean', 'postgres', '13112003', {
  host: 'localhost', // e.g., 'localhost'
  dialect: 'postgres', // Use PostgreSQL
  logging: false, // Disable logging (optional)
  port: 5432,
});

module.exports = sequelize;
