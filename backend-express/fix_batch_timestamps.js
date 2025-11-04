const { sequelize } = require('./src/models');

async function fixBatchTimestamps() {
    try {
        logger.log('🔧 Fixing batch prediction timestamps...');

        // 1. Kiểm tra cấu trúc bảng hiện tại
        logger.log('\n1. Checking current table structure...');
        const tableInfo = await sequelize.query(
            "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_name = 'diagnose_predictions' ORDER BY ordinal_position",
            { type: sequelize.QueryTypes.SELECT }
        );

        logger.log('Current columns:');
        tableInfo.forEach(column => {
            logger.log(`   ${column.column_name}: ${column.data_type} (nullable: ${column.is_nullable})`);
        });

        // 2. Thêm cột timestamps nếu chưa có
        logger.log('\n2. Adding timestamp columns if missing...');

        const hasCreatedAt = tableInfo.some(col => col.column_name === 'createdAt');
        const hasUpdatedAt = tableInfo.some(col => col.column_name === 'updatedAt');

        if (!hasCreatedAt) {
            logger.log('Adding createdAt column...');
            await sequelize.query(`
        ALTER TABLE diagnose_predictions 
        ADD COLUMN "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
      `);
        }

        if (!hasUpdatedAt) {
            logger.log('Adding updatedAt column...');
            await sequelize.query(`
        ALTER TABLE diagnose_predictions 
        ADD COLUMN "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
      `);
        }

        // 3. Cập nhật các record cũ không có timestamp
        logger.log('\n3. Updating old records without timestamps...');
        const updateResult = await sequelize.query(`
      UPDATE diagnose_predictions 
      SET "createdAt" = NOW(), "updatedAt" = NOW() 
      WHERE "createdAt" IS NULL OR "updatedAt" IS NULL
    `);

        logger.log(`Updated ${updateResult[1]} records`);

        // 4. Kiểm tra kết quả
        logger.log('\n4. Verifying results...');
        const recentPredictions = await sequelize.query(`
      SELECT id, "createdAt", "updatedAt" 
      FROM diagnose_predictions 
      ORDER BY id DESC 
      LIMIT 5
    `, { type: sequelize.QueryTypes.SELECT });

        logger.log('Recent predictions with timestamps:');
        recentPredictions.forEach(prediction => {
            logger.log(`   ID ${prediction.id}: createdAt=${prediction.createdAt}, updatedAt=${prediction.updatedAt}`);
        });

        logger.log('\n✅ Timestamp fix completed successfully!');

    } catch (error) {
        logger.error('❌ Error fixing timestamps:', error);
    } finally {
        await sequelize.close();
        process.exit(0);
    }
}

fixBatchTimestamps();
