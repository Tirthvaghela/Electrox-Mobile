const axios = require('axios');
require('dotenv').config();

async function testOrganizationAPI() {
  try {
    const baseURL = 'http://localhost:5000/api';
    
    // Login as admin
    console.log('🔐 Logging in as admin...');
    const loginResponse = await axios.post(`${baseURL}/auth/login`, {
      email: 'admin@electrox.com',
      password: 'admin123'
    });
    
    const token = loginResponse.data.token;
    console.log('✅ Login successful');
    
    // Get organizations
    console.log('📋 Fetching organizations...');
    const orgResponse = await axios.get(`${baseURL}/organization/all`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('✅ Organizations fetched:');
    console.log(JSON.stringify(orgResponse.data, null, 2));
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testOrganizationAPI();