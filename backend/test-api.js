const axios = require('axios');

async function testLogin() {
  try {
    console.log('🧪 Testing login endpoint...\n');
    
    const response = await axios.post('http://localhost:5000/api/auth/login', {
      email: 'admin@electrox.com',
      password: 'admin123'
    });

    console.log('✅ Login successful!');
    console.log('📊 Response:', JSON.stringify(response.data, null, 2));
    console.log('\n🎉 Backend API is working correctly!');
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data || error.message);
  }
}

testLogin();
