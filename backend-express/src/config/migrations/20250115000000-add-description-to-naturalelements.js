'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.addColumn('diagnose_naturalelements', 'description', {
            type: Sequelize.TEXT,
            allowNull: true,
        });

        await queryInterface.addColumn('diagnose_naturalelements', 'unit', {
            type: Sequelize.STRING,
            allowNull: true,
        });

        await queryInterface.addColumn('diagnose_naturalelements', 'category', {
            type: Sequelize.STRING,
            allowNull: true,
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.removeColumn('diagnose_naturalelements', 'description');
        await queryInterface.removeColumn('diagnose_naturalelements', 'unit');
        await queryInterface.removeColumn('diagnose_naturalelements', 'category');
    }
};
