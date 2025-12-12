'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('model_nature_elements', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      model_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'ml_models',
          key: 'id',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
        comment: 'ID của ML model',
      },
      nature_element_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'diagnose_naturalelements',
          key: 'id',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
        comment: 'ID của yếu tố môi trường',
      },
      is_required: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        comment: 'Yếu tố này có bắt buộc cho model không',
      },
      input_order: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
        comment: 'Thứ tự input vào model',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    // Add unique constraint
    await queryInterface.addConstraint('model_nature_elements', {
      fields: ['model_id', 'nature_element_id'],
      type: 'unique',
      name: 'unique_model_nature_element',
    });

    // Add indexes
    await queryInterface.addIndex('model_nature_elements', ['model_id']);
    await queryInterface.addIndex('model_nature_elements', ['nature_element_id']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('model_nature_elements');
  },
};

