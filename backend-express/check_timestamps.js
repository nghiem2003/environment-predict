const { Prediction } = require('./src/models');

// Script để kiểm tra timestamps trong database
async function checkTimestamps() {
    try {
        console.log('Checking timestamps in database...');

        // Lấy 5 prediction mới nhất
        const recentPredictions = await Prediction.findAll({
            order: [['id', 'DESC']],
            limit: 5,
            attributes: ['id', 'user_id', 'area_id', 'prediction_text', 'createdAt', 'updatedAt']
        });

        console.log(`\nFound ${recentPredictions.length} recent predictions:`);

        recentPredictions.forEach((prediction, index) => {
            console.log(`\n${index + 1}. Prediction ID: ${prediction.id}`);
            console.log(`   User ID: ${prediction.user_id}`);
            console.log(`   Area ID: ${prediction.area_id}`);
            console.log(`   Prediction Text: ${prediction.prediction_text}`);
            console.log(`   Created At: ${prediction.createdAt}`);
            console.log(`   Updated At: ${prediction.updatedAt}`);

            if (prediction.createdAt) {
                console.log('   ✅ Has timestamp');
            } else {
                console.log('   ❌ Missing timestamp');
            }
        });

        // Kiểm tra cấu trúc bảng
        console.log('\n📋 Table structure check:');
        const tableInfo = await Prediction.sequelize.query(
            "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_name = 'diagnose_predictions' ORDER BY ordinal_position",
            { type: Prediction.sequelize.QueryTypes.SELECT }
        );

        tableInfo.forEach(column => {
            console.log(`   ${column.column_name}: ${column.data_type} (nullable: ${column.is_nullable}, default: ${column.column_default})`);
        });

    } catch (error) {
        console.error('Error checking timestamps:', error);
    } finally {
        process.exit(0);
    }
}

checkTimestamps();
