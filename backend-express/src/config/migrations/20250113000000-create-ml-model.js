'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('ml_models', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true,
        comment: 'Tên model học máy',
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
        comment: 'Mô tả chi tiết về model',
      },
      model_file_path: {
        type: Sequelize.STRING(500),
        allowNull: true,
        comment: 'Đường dẫn tới file model (.pkl, .h5, etc.)',
      },
      area_type: {
        type: Sequelize.ENUM('oyster', 'cobia'),
        allowNull: true,
        comment: 'Loại khu vực áp dụng model',
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
        comment: 'Trạng thái kích hoạt model',
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

    // Add indexes
    await queryInterface.addIndex('ml_models', ['is_active']);
    await queryInterface.addIndex('ml_models', ['area_type']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('ml_models');
  },
};

