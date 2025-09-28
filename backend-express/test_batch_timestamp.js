const axios = require('axios');

// Test script để kiểm tra batch prediction có tạo timestamp đúng không
async function testBatchPredictionTimestamp() {
    try {
        console.log('Testing batch prediction timestamp...');

        // Test data với timestamp tùy chỉnh
        const customDate = new Date('2024-01-15T10:30:00Z');
        const testData = {
            userId: 1, // Thay đổi theo user ID thực tế
            areaId: 1, // Thay đổi theo area ID thực tế
            modelName: 'cobia_ridge',
            data: [
                {
                    R_PO4: 0.1,
                    O2Sat: 95.5,
                    O2ml_L: 8.2,
                    STheta: 25.0,
                    Salnty: 35.0,
                    R_DYNHT: 0.5,
                    T_degC: 28.0,
                    R_Depth: 2.0,
                    Distance: 100.0,
                    Wind_Spd: 5.0,
                    Wave_Ht: 1.0,
                    Wave_Prd: 8.0,
                    IntChl: 0.5,
                    Dry_T: 0.3,
                    createdAt: customDate.toISOString() // Timestamp tùy chỉnh
                },
                {
                    R_PO4: 0.2,
                    O2Sat: 96.0,
                    O2ml_L: 8.5,
                    STheta: 26.0,
                    Salnty: 36.0,
                    R_DYNHT: 0.6,
                    T_degC: 29.0,
                    R_Depth: 2.5,
                    Distance: 150.0,
                    Wind_Spd: 6.0,
                    Wave_Ht: 1.2,
                    Wave_Prd: 9.0,
                    IntChl: 0.6,
                    Dry_T: 0.4
                    // Không có createdAt - sẽ dùng thời điểm hiện tại
                }
            ]
        };

        console.log('Sending batch prediction request...');
        const response = await axios.post('http://localhost:5000/api/express/predictions/batch', testData, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer YOUR_TOKEN_HERE' // Thay đổi token thực tế
            }
        });

        console.log('Batch prediction response:', response.data);

        // Kiểm tra xem có prediction IDs không
        if (response.data.predictions && response.data.predictions.length > 0) {
            console.log('\n✅ Batch prediction created successfully!');
            console.log('Number of predictions created:', response.data.predictions.length);

            // Lấy chi tiết từng prediction để kiểm tra timestamp
            for (let i = 0; i < response.data.predictions.length; i++) {
                const prediction = response.data.predictions[i];
                const isCustomTimestamp = i === 0; // Prediction đầu tiên có custom timestamp

                try {
                    const detailResponse = await axios.get(`http://localhost:5000/api/express/predictions/${prediction.prediction_id}`, {
                        headers: {
                            'Authorization': 'Bearer YOUR_TOKEN_HERE' // Thay đổi token thực tế
                        }
                    });

                    const predictionDetail = detailResponse.data;
                    console.log(`\n📊 Prediction ID: ${prediction.prediction_id}`);
                    console.log(`📅 Created At: ${predictionDetail.createdAt}`);
                    console.log(`🔄 Updated At: ${predictionDetail.updatedAt}`);

                    if (predictionDetail.createdAt) {
                        if (isCustomTimestamp) {
                            const customTime = new Date(customDate);
                            const actualTime = new Date(predictionDetail.createdAt);
                            const timeDiff = Math.abs(actualTime - customTime);

                            if (timeDiff < 1000) { // Chênh lệch dưới 1 giây
                                console.log('✅ Custom timestamp applied correctly!');
                            } else {
                                console.log('⚠️ Custom timestamp may not be applied correctly');
                                console.log(`   Expected: ${customTime.toISOString()}`);
                                console.log(`   Actual: ${actualTime.toISOString()}`);
                            }
                        } else {
                            console.log('✅ Auto timestamp applied correctly!');
                        }
                    } else {
                        console.log('❌ No timestamp found!');
                    }
                } catch (detailError) {
                    console.error('Error fetching prediction details:', detailError.message);
                }
            }
        } else {
            console.log('❌ No predictions created');
        }

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
    }
}

// Chạy test
testBatchPredictionTimestamp();
