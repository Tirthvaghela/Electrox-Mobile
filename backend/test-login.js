const axios = require('axios');

async function testLogin() {
  try {
    console.log('🧪 Testing login endpoint...');
    console.log('📍 URL: http://192.168.0.102:5000/api/auth/login');
    console.log('📧 Email: admin@electrox.com');
    console.log('🔑 Password: admin123\n');

    const response = await axios.post('http://192.168.0.102:5000/api/auth/login', {
      email: 'admin@electrox.com',
      password: 'admin123'
    });

    console.log('✅ Login successful!');
    console.log('📦 Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    if (error.response) {
      console.log('❌ Login failed!');
      console.log('Status:', error.response.status);
      console.log('Message:', error.response.data);
    } else {
      console.log('❌ Network error:', error.message);
    }
  }
}

testLogin();
