const { NatureElement } = require('../src/models');
const sequelize = require('../src/config/db');

// Định nghĩa thông tin chi tiết cho các natural elements
const naturalElementsData = {
    'R_PO4': {
        description: 'Reactive Phosphorus - Phospho phản ứng, một dạng phospho có thể được thực vật thủy sinh sử dụng trực tiếp',
        unit: 'mg/L',
        category: 'Nutrients'
    },
    'O2Sat': {
        description: 'Oxygen Saturation - Độ bão hòa oxy trong nước, tỷ lệ phần trăm oxy hòa tan so với khả năng hòa tan tối đa',
        unit: '%',
        category: 'Water Quality'
    },
    'O2ml_L': {
        description: 'Oxygen Concentration - Nồng độ oxy hòa tan trong nước, đo bằng ml oxy trên 1 lít nước',
        unit: 'ml/L',
        category: 'Water Quality'
    },
    'STheta': {
        description: 'Potential Temperature - Nhiệt độ tiềm năng, nhiệt độ nước sau khi điều chỉnh áp suất về mực nước biển',
        unit: '°C',
        category: 'Physical Properties'
    },
    'Salnty': {
        description: 'Salinity - Độ mặn của nước, tổng lượng muối hòa tan trong nước',
        unit: 'PSU (Practical Salinity Units)',
        category: 'Physical Properties'
    },
    'R_DYNHT': {
        description: 'Dynamic Height - Chiều cao động lực, đo sự chênh lệch mực nước do dòng chảy',
        unit: 'm',
        category: 'Physical Properties'
    },
    'T_degC': {
        description: 'Temperature - Nhiệt độ nước, ảnh hưởng đến tốc độ phản ứng sinh hóa và sự phát triển của sinh vật',
        unit: '°C',
        category: 'Physical Properties'
    },
    'R_Depth': {
        description: 'Depth - Độ sâu của nước, khoảng cách từ mặt nước đến đáy',
        unit: 'm',
        category: 'Physical Properties'
    },
    'Distance': {
        description: 'Distance from Shore - Khoảng cách từ bờ biển, ảnh hưởng đến điều kiện môi trường',
        unit: 'km',
        category: 'Location'
    },
    'Wind_Spd': {
        description: 'Wind Speed - Tốc độ gió, ảnh hưởng đến sóng và dòng chảy nước',
        unit: 'm/s',
        category: 'Atmospheric'
    },
    'Wave_Ht': {
        description: 'Wave Height - Chiều cao sóng, đo từ đáy đến đỉnh sóng',
        unit: 'm',
        category: 'Atmospheric'
    },
    'Wave_Prd': {
        description: 'Wave Period - Chu kỳ sóng, thời gian giữa hai đỉnh sóng liên tiếp',
        unit: 's',
        category: 'Atmospheric'
    },
    'IntChl': {
        description: 'Integrated Chlorophyll - Chlorophyll tích hợp, tổng lượng chlorophyll trong cột nước, chỉ thị mật độ tảo',
        unit: 'mg/m²',
        category: 'Biological'
    },
    'Dry_T': {
        description: 'Dry Temperature - Nhiệt độ khô, nhiệt độ không khí không có độ ẩm',
        unit: '°C',
        category: 'Atmospheric'
    }
};

async function updateNaturalElements() {
    try {
        console.log('🚀 Bắt đầu cập nhật Natural Elements...\n');

        // Kết nối database
        await sequelize.authenticate();
        console.log('✅ Kết nối database thành công');

        // Lấy tất cả natural elements hiện có
        const existingElements = await NatureElement.findAll();
        console.log(`📊 Tìm thấy ${existingElements.length} natural elements trong database`);

        let updatedCount = 0;
        let addedCount = 0;

        // Cập nhật các elements hiện có
        for (const element of existingElements) {
            const elementData = naturalElementsData[element.name];

            if (elementData) {
                await element.update({
                    description: elementData.description,
                    unit: elementData.unit,
                    category: elementData.category
                });

                console.log(`✅ Cập nhật: ${element.name} - ${elementData.description.substring(0, 50)}...`);
                updatedCount++;
            } else {
                console.log(`⚠️  Không tìm thấy thông tin cho: ${element.name}`);
            }
        }

        // Thêm các elements mới nếu chưa có
        for (const [name, data] of Object.entries(naturalElementsData)) {
            const existingElement = existingElements.find(el => el.name === name);

            if (!existingElement) {
                await NatureElement.create({
                    name: name,
                    description: data.description,
                    unit: data.unit,
                    category: data.category
                });

                console.log(`➕ Thêm mới: ${name} - ${data.description.substring(0, 50)}...`);
                addedCount++;
            }
        }

        console.log('\n📈 Kết quả:');
        console.log(`- Đã cập nhật: ${updatedCount} elements`);
        console.log(`- Đã thêm mới: ${addedCount} elements`);
        console.log(`- Tổng cộng: ${updatedCount + addedCount} elements được xử lý`);

        // Hiển thị danh sách tất cả elements sau khi cập nhật
        console.log('\n📋 Danh sách Natural Elements sau khi cập nhật:');
        const allElements = await NatureElement.findAll({
            order: [['category', 'ASC'], ['name', 'ASC']]
        });

        allElements.forEach(element => {
            console.log(`\n🔹 ${element.name} (${element.category})`);
            console.log(`   Mô tả: ${element.description}`);
            console.log(`   Đơn vị: ${element.unit}`);
        });

    } catch (error) {
        console.error('❌ Lỗi khi cập nhật Natural Elements:', error);
    } finally {
        await sequelize.close();
        console.log('\n🔌 Đã đóng kết nối database');
    }
}

// Chạy script
if (require.main === module) {
    updateNaturalElements();
}

module.exports = { updateNaturalElements, naturalElementsData };
