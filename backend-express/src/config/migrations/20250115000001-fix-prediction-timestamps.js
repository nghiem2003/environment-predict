'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Kiểm tra xem cột createdAt và updatedAt đã tồn tại chưa
        const tableDescription = await queryInterface.describeTable('diagnose_predictions');

        // Thêm cột createdAt nếu chưa có
        if (!tableDescription.createdAt) {
            await queryInterface.addColumn('diagnose_predictions', 'createdAt', {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.NOW
            });
        }

        // Thêm cột updatedAt nếu chưa có
        if (!tableDescription.updatedAt) {
            await queryInterface.addColumn('diagnose_predictions', 'updatedAt', {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.NOW
            });
        }

        // Cập nhật các record cũ không có timestamp
        await queryInterface.sequelize.query(`
      UPDATE diagnose_predictions 
      SET "createdAt" = NOW(), "updatedAt" = NOW() 
      WHERE "createdAt" IS NULL OR "updatedAt" IS NULL
    `);
    },

    async down(queryInterface, Sequelize) {
        // Xóa cột createdAt và updatedAt nếu cần rollback
        await queryInterface.removeColumn('diagnose_predictions', 'createdAt');
        await queryInterface.removeColumn('diagnose_predictions', 'updatedAt');
    }
};
