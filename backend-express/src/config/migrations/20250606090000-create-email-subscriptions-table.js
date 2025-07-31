'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('email_subscriptions', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        validate: {
          isEmail: true,
        },
      },
      area_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'diagnose_areas',
          key: 'id',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      unsubscribe_token: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    // Add unique constraint to prevent duplicate email-area pairs
    await queryInterface.addConstraint('email_subscriptions', {
      fields: ['email', 'area_id'],
      type: 'unique',
      name: 'unique_email_area_pair',
    });

    // Add index for better query performance
    await queryInterface.addIndex('email_subscriptions', ['area_id']);
    await queryInterface.addIndex('email_subscriptions', ['email']);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('email_subscriptions');
  },
};
