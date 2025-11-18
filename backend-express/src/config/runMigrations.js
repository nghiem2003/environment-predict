const { execSync } = require('child_process');
const path = require('path');
const logger = require('./logger');

async function runMigrations() {
    try {
        logger.info('🚀 Bắt đầu chạy migrations...');

        // Chạy migrations
        try {
            execSync('npx sequelize-cli db:migrate', {
                cwd: path.join(__dirname, '..', '..'),
                stdio: 'inherit',
                env: { ...process.env, NODE_ENV: process.env.NODE_ENV || 'development' }
            });
            logger.info('✅ Migrations thành công');
        } catch (error) {
            logger.warn('⚠️  Migration có thể đã chạy trước đó hoặc có lỗi:', error.message);
        }

        // Chạy seeders
        try {
            execSync('npx sequelize-cli db:seed:all', {
                cwd: path.join(__dirname, '..', '..'),
                stdio: 'inherit',
                env: { ...process.env, NODE_ENV: process.env.NODE_ENV || 'development' }
            });
            logger.info('✅ Seeders thành công');
        } catch (error) {
            logger.warn('⚠️  Seeders có thể đã chạy trước đó hoặc có lỗi:', error.message);
        }

        logger.info('🎉 Hoàn thành migrations và seeders!');
    } catch (error) {
        logger.error('❌ Lỗi khi chạy migrations:', error);
        throw error;
    }
}

module.exports = { runMigrations };



