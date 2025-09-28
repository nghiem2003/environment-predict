const { execSync } = require('child_process');
const path = require('path');

async function runMigrationAndUpdate() {
    try {
        console.log('🚀 Bắt đầu chạy migration và cập nhật Natural Elements...\n');

        // 1. Chạy migration để thêm các cột mới
        console.log('📋 Bước 1: Chạy migration để thêm description, unit, category...');
        try {
            execSync('npx sequelize-cli db:migrate', {
                cwd: path.join(__dirname, '..'),
                stdio: 'inherit'
            });
            console.log('✅ Migration thành công');
        } catch (error) {
            console.log('⚠️  Migration có thể đã chạy trước đó hoặc có lỗi:', error.message);
        }

        // 2. Chạy script cập nhật dữ liệu
        console.log('\n📊 Bước 2: Cập nhật dữ liệu Natural Elements...');
        const { updateNaturalElements } = require('./update_natural_elements');
        await updateNaturalElements();

        console.log('\n🎉 Hoàn thành tất cả các bước!');
        console.log('\n📝 Các API endpoints đã sẵn sàng:');
        console.log('- GET /api/express/nature-elements - Lấy danh sách natural elements');
        console.log('- GET /api/express/nature-elements/categories - Lấy danh sách categories');
        console.log('- GET /api/express/nature-elements/category/:category - Lấy elements theo category');
        console.log('- GET /api/express/predictions/chart/data - Chart API với description');
        console.log('- GET /api/express/predictions/chart/all - Chart API cho tất cả areas');

    } catch (error) {
        console.error('❌ Lỗi khi chạy migration và cập nhật:', error);
        process.exit(1);
    }
}

// Chạy script
if (require.main === module) {
    runMigrationAndUpdate();
}

module.exports = { runMigrationAndUpdate };
