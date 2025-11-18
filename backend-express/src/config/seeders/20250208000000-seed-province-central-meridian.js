'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        const { v4: uuidv4 } = require('uuid');

        // Dữ liệu tỉnh và kinh tuyến trục (34 tỉnh)
        const provincesData = [
            {
                "name": "An Giang",
                "central_meridian": 104.75
            },
            {
                "name": "Cà Mau",
                "central_meridian": 104.50
            },
            {
                "name": "Cần Thơ",
                "central_meridian": 105.00
            },
            {
                "name": "Đà Nẵng",
                "central_meridian": 107.75
            },
            {
                "name": "Đắk Lắk",
                "central_meridian": 108.50
            },
            {
                "name": "Điện Biên",
                "central_meridian": 103.00
            },
            {
                "name": "Đồng Nai",
                "central_meridian": 107.75
            },
            {
                "name": "Đồng Tháp",
                "central_meridian": 105.00
            },
            {
                "name": "Gia Lai",
                "central_meridian": 108.25
            },
            {
                "name": "Hà Nội",
                "central_meridian": 105.00
            },
            {
                "name": "Hà Tĩnh",
                "central_meridian": 105.50
            },
            {
                "name": "Hải Phòng",
                "central_meridian": 105.75
            },
            {
                "name": "Hưng Yên",
                "central_meridian": 105.50
            },
            {
                "name": "Khánh Hoà",
                "central_meridian": 108.25
            },
            {
                "name": "Lào Cai",
                "central_meridian": 104.75
            },
            {
                "name": "Thừa Thiên Huế",
                "central_meridian": 107
            },
            {
                "name": "Lạng Sơn",
                "central_meridian": 107.25
            },
            {
                "name": "Lâm Đồng",
                "central_meridian": 107.75
            },
            {
                "name": "Nghệ An",
                "central_meridian": 104.75
            },
            {
                "name": "Ninh Bình",
                "central_meridian": 105.00
            },
            {
                "name": "Phú Thọ",
                "central_meridian": 104.75
            },
            {
                "name": "Quảng Ngãi",
                "central_meridian": 108.00
            },
            {
                "name": "Quảng Ninh",
                "central_meridian": 107.75
            },
            {
                "name": "Quảng Trị",
                "central_meridian": 106.00
            },
            {
                "name": "Sơn La",
                "central_meridian": 104.00
            },
            {
                "name": "Tây Ninh",
                "central_meridian": 105.75
            },
            {
                "name": "Thanh Hoá",
                "central_meridian": 105.00
            },
            {
                "name": "Thái Nguyên",
                "central_meridian": 106.50
            },
            {
                "name": "TP Hồ Chí Minh",
                "central_meridian": 105.75
            },
            {
                "name": "Tuyên Quang",
                "central_meridian": 106.00
            },
            {
                "name": "Lai Châu",
                "central_meridian": 103.00
            },
            {
                "name": "Cao Bằng",
                "central_meridian": 105.75
            },
            {
                "name": "Bắc Ninh",
                "central_meridian": 107.00
            },
            {
                "name": "Vĩnh Long",
                "central_meridian": 105.50
            }
        ];

        // Lấy tất cả tỉnh hiện có
        const [existingProvinces] = await queryInterface.sequelize.query(
            'SELECT id, name FROM provinces'
        );

        const existingNames = new Map(
            existingProvinces.map(p => [p.name.toLowerCase().trim(), p])
        );

        // Cập nhật hoặc tạo mới tỉnh
        for (const province of provincesData) {
            const normalizedName = province.name.toLowerCase().trim();
            const existing = existingNames.get(normalizedName);

            if (existing) {
                // Cập nhật central_meridian cho tỉnh đã có
                await queryInterface.sequelize.query(
                    `UPDATE provinces SET central_meridian = :meridian WHERE id = :id`,
                    {
                        replacements: {
                            meridian: province.central_meridian,
                            id: existing.id
                        }
                    }
                );
            } else {
                // Tạo mới tỉnh
                await queryInterface.bulkInsert('provinces', [{
                    id: uuidv4(),
                    name: province.name,
                    central_meridian: province.central_meridian
                }]);
            }
        }
    },

    async down(queryInterface, Sequelize) {
        // Xóa tất cả central_meridian
        await queryInterface.sequelize.query(
            'UPDATE provinces SET central_meridian = NULL'
        );
    }
};

