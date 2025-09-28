const axios = require('axios');

// Test batch prediction with email notification
async function testBatchPredictionEmail() {
    try {
        console.log('🚀 Testing Batch Prediction with Email Notification...\n');

        const baseUrl = 'http://localhost:5000/api/express/predictions';

        // Sample batch prediction data
        const batchData = {
            userId: 1,
            areaId: 1,
            modelName: 'oyster_lightgbm',
            data: [
                {
                    R_PO4: 0.1,
                    O2Sat: 85.5,
                    O2ml_L: 6.2,
                    STheta: 28.3,
                    Salnty: 32.1,
                    R_DYNHT: 0.5,
                    T_degC: 28.5,
                    R_Depth: 5.0,
                    Distance: 2.3,
                    Wind_Spd: 3.2,
                    Wave_Ht: 0.8,
                    Wave_Prd: 4.5,
                    IntChl: 2.1,
                    Dry_T: 30.2,
                    createdAt: new Date().toISOString()
                },
                {
                    R_PO4: 0.15,
                    O2Sat: 88.2,
                    O2ml_L: 6.5,
                    STheta: 28.8,
                    Salnty: 31.8,
                    R_DYNHT: 0.6,
                    T_degC: 29.1,
                    R_Depth: 4.8,
                    Distance: 2.1,
                    Wind_Spd: 2.8,
                    Wave_Ht: 0.6,
                    Wave_Prd: 4.2,
                    IntChl: 2.3,
                    Dry_T: 30.8,
                    createdAt: new Date().toISOString()
                },
                {
                    R_PO4: 0.12,
                    O2Sat: 87.1,
                    O2ml_L: 6.3,
                    STheta: 28.6,
                    Salnty: 32.0,
                    R_DYNHT: 0.55,
                    T_degC: 28.8,
                    R_Depth: 4.9,
                    Distance: 2.2,
                    Wind_Spd: 3.0,
                    Wave_Ht: 0.7,
                    Wave_Prd: 4.3,
                    IntChl: 2.2,
                    Dry_T: 30.5,
                    createdAt: new Date().toISOString()
                }
            ]
        };

        console.log(`Testing POST ${baseUrl}/batch`);
        console.log('Batch data:', JSON.stringify(batchData, null, 2));

        const response = await axios.post(`${baseUrl}/batch`, batchData);

        console.log('✅ Batch Prediction Response Status:', response.status);
        console.log('✅ Batch Prediction Response Data:');
        console.log(JSON.stringify(response.data, null, 2));

        // Validate response structure
        const { predictions, model_used } = response.data;

        if (predictions && Array.isArray(predictions)) {
            console.log('\n✅ Batch Prediction validation:');
            console.log('- Number of predictions created:', predictions.length);
            console.log('- Model used:', model_used);

            predictions.forEach((prediction, index) => {
                console.log(`\n📊 Prediction ${index + 1}:`);
                console.log('- ID:', prediction.prediction_id);
                console.log('- Result:', prediction.prediction_text);
                console.log('- Inputs keys:', Object.keys(prediction.inputs || {}));
            });

            console.log('\n📧 Email notifications should have been sent to subscribers for area ID:', batchData.areaId);
            console.log('Check your email inbox for batch prediction notifications!');
        }

    } catch (error) {
        console.error('❌ Error testing Batch Prediction:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        } else {
            console.error('Message:', error.message);
        }
    }
}

// Test single prediction for comparison
async function testSinglePrediction() {
    try {
        console.log('\n\n🔍 Testing Single Prediction for comparison...\n');

        const baseUrl = 'http://localhost:5000/api/express/predictions';

        const singleData = {
            userId: 1,
            areaId: 1,
            inputs: {
                R_PO4: 0.1,
                O2Sat: 85.5,
                O2ml_L: 6.2,
                STheta: 28.3,
                Salnty: 32.1,
                R_DYNHT: 0.5,
                T_degC: 28.5,
                R_Depth: 5.0,
                Distance: 2.3,
                Wind_Spd: 3.2,
                Wave_Ht: 0.8,
                Wave_Prd: 4.5,
                IntChl: 2.1,
                Dry_T: 30.2
            },
            modelName: 'oyster_lightgbm'
        };

        console.log(`Testing POST ${baseUrl}/`);

        const response = await axios.post(`${baseUrl}/`, singleData);

        console.log('✅ Single Prediction Response Status:', response.status);
        console.log('✅ Single Prediction Response Data:');
        console.log(JSON.stringify(response.data, null, 2));

        console.log('\n📧 Email notification should have been sent for single prediction too!');

    } catch (error) {
        console.error('❌ Error testing Single Prediction:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        } else {
            console.error('Message:', error.message);
        }
    }
}

// Run tests
async function runTests() {
    console.log('🚀 Starting Batch Prediction Email Tests\n');
    console.log('Make sure your backend server is running on http://localhost:5000\n');
    console.log('Make sure you have email subscriptions for area ID 1\n');

    await testSinglePrediction();
    await testBatchPredictionEmail();

    console.log('\n🏁 Tests completed!');
    console.log('\n📝 Check your email inbox for notifications!');
}

runTests();
