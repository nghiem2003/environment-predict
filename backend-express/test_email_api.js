const axios = require('axios');

const BASE_URL = 'http://localhost:3001/api/express';

// Test functions
async function testEmailAPIs() {
  console.log('Testing Email APIs...\n');

  try {
    // Test 1: Get area by ID
    console.log('1. Testing GET /areas/area/:id');
    try {
      const areaResponse = await axios.get(`${BASE_URL}/areas/area/1`);
      console.log('✅ Area API working:', areaResponse.data.name);
    } catch (error) {
      console.log(
        '❌ Area API failed:',
        error.response?.data?.error || error.message
      );
    }

    // Test 2: Subscribe to email
    console.log('\n2. Testing POST /emails/subscribe');
    try {
      const subscribeResponse = await axios.post(
        `${BASE_URL}/emails/subscribe`,
        {
          email: 'test@example.com',
          area_id: 1,
        }
      );
      console.log('✅ Subscribe API working:', subscribeResponse.data.message);
    } catch (error) {
      console.log(
        '❌ Subscribe API failed:',
        error.response?.data?.error || error.message
      );
    }

    // Test 3: Get all email subscriptions (requires admin token)
    console.log('\n3. Testing GET /emails (admin only)');
    try {
      const subscriptionsResponse = await axios.get(`${BASE_URL}/emails`);
      console.log(
        '✅ Get subscriptions API working:',
        subscriptionsResponse.data.subscriptions?.length || 0,
        'subscriptions'
      );
    } catch (error) {
      console.log(
        '❌ Get subscriptions API failed (expected for non-admin):',
        error.response?.status
      );
    }

    // Test 4: Test email sending (requires admin token)
    console.log('\n4. Testing POST /emails/test (admin only)');
    try {
      const testResponse = await axios.post(`${BASE_URL}/emails/test`, {
        email: 'test@example.com',
      });
      console.log('✅ Test email API working:', testResponse.data.message);
    } catch (error) {
      console.log(
        '❌ Test email API failed (expected for non-admin):',
        error.response?.status
      );
    }

    console.log('\n✅ Email API tests completed!');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Run tests
testEmailAPIs();
