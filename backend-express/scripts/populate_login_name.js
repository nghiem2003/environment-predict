const { User } = require('../src/models');
const logger = require('../src/config/logger');

async function populateLoginName() {
    try {
        logger.info('🚀 Bắt đầu cập nhật login_name từ email...');

        // Tìm tất cả users có login_name null hoặc empty
        const users = await User.findAll({
            where: {
                email: { [require('sequelize').Op.ne]: null },
            },
            raw: true
        });

        logger.info(`📊 Tìm thấy ${users.length} user(s) trong database`);

        let updatedCount = 0;
        let skippedCount = 0;

        for (const user of users) {
            // Nếu login_name đã tồn tại và không rỗng, bỏ qua
            if (user.login_name && user.login_name.trim() !== '') {
                skippedCount++;
                continue;
            }

            if (user.email) {
                // Lấy phần trước dấu @
                const loginName = user.email.split('@')[0].trim();

                logger.info(`📝 Cập nhật user ID ${user.id}: "${user.email}" -> login_name="${loginName}"`);

                await User.update(
                    { login_name: loginName },
                    { where: { id: user.id } }
                );

                updatedCount++;
            } else {
                logger.warn(`⚠️  User ID ${user.id} không có email, bỏ qua`);
                skippedCount++;
            }
        }

        logger.info(`✅ Hoàn thành cập nhật login_name:`);
        logger.info(`   - Đã cập nhật: ${updatedCount} user(s)`);
        logger.info(`   - Đã bỏ qua: ${skippedCount} user(s)`);

    } catch (error) {
        logger.error('❌ Lỗi khi cập nhật login_name:', error);
        throw error;
    }
}

// Chạy script nếu được gọi trực tiếp
if (require.main === module) {
    populateLoginName()
        .then(() => {
            logger.info('🎉 Script hoàn thành!');
            process.exit(0);
        })
        .catch((error) => {
            logger.error('💥 Script thất bại:', error);
            process.exit(1);
        });
}

module.exports = { populateLoginName };

