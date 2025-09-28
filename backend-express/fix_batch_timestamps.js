const { sequelize } = require('./src/models');

async function fixBatchTimestamps() {
    try {
        console.log('🔧 Fixing batch prediction timestamps...');

        // 1. Kiểm tra cấu trúc bảng hiện tại
        console.log('\n1. Checking current table structure...');
        const tableInfo = await sequelize.query(
            "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_name = 'diagnose_predictions' ORDER BY ordinal_position",
            { type: sequelize.QueryTypes.SELECT }
        );

        console.log('Current columns:');
        tableInfo.forEach(column => {
            console.log(`   ${column.column_name}: ${column.data_type} (nullable: ${column.is_nullable})`);
        });

        // 2. Thêm cột timestamps nếu chưa có
        console.log('\n2. Adding timestamp columns if missing...');

        const hasCreatedAt = tableInfo.some(col => col.column_name === 'createdAt');
        const hasUpdatedAt = tableInfo.some(col => col.column_name === 'updatedAt');

        if (!hasCreatedAt) {
            console.log('Adding createdAt column...');
            await sequelize.query(`
        ALTER TABLE diagnose_predictions 
        ADD COLUMN "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
      `);
        }

        if (!hasUpdatedAt) {
            console.log('Adding updatedAt column...');
            await sequelize.query(`
        ALTER TABLE diagnose_predictions 
        ADD COLUMN "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
      `);
        }

        // 3. Cập nhật các record cũ không có timestamp
        console.log('\n3. Updating old records without timestamps...');
        const updateResult = await sequelize.query(`
      UPDATE diagnose_predictions 
      SET "createdAt" = NOW(), "updatedAt" = NOW() 
      WHERE "createdAt" IS NULL OR "updatedAt" IS NULL
    `);

        console.log(`Updated ${updateResult[1]} records`);

        // 4. Kiểm tra kết quả
        console.log('\n4. Verifying results...');
        const recentPredictions = await sequelize.query(`
      SELECT id, "createdAt", "updatedAt" 
      FROM diagnose_predictions 
      ORDER BY id DESC 
      LIMIT 5
    `, { type: sequelize.QueryTypes.SELECT });

        console.log('Recent predictions with timestamps:');
        recentPredictions.forEach(prediction => {
            console.log(`   ID ${prediction.id}: createdAt=${prediction.createdAt}, updatedAt=${prediction.updatedAt}`);
        });

        console.log('\n✅ Timestamp fix completed successfully!');

    } catch (error) {
        console.error('❌ Error fixing timestamps:', error);
    } finally {
        await sequelize.close();
        process.exit(0);
    }
}

fixBatchTimestamps();
