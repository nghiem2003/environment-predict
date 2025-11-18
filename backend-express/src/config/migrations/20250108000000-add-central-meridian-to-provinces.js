'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Kiểm tra xem cột central_meridian đã tồn tại chưa
        const tableDescription = await queryInterface.describeTable('provinces');

        if (!tableDescription.central_meridian) {
            await queryInterface.addColumn('provinces', 'central_meridian', {
                type: Sequelize.DOUBLE,
                allowNull: true,
                comment: 'Kinh tuyến trục VN2000 (độ)'
            });
        }
    },

    async down(queryInterface, Sequelize) {
        // Xóa cột central_meridian nếu cần rollback
        const tableDescription = await queryInterface.describeTable('provinces');
        if (tableDescription.central_meridian) {
            await queryInterface.removeColumn('provinces', 'central_meridian');
        }
    }
};



