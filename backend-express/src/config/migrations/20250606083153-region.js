'use strict';


module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.renameTable('regions', 'provinces');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.renameTable('provinces', 'regions');
  }
};