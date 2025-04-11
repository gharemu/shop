const bcrypt = require('bcrypt');
const pool = require('../config/db.config');

async function verifyLogin() {
  try {
    const email = 'admin@example.com';
    const password = 'admin123';
    
    // Get user from database
    const query = 'SELECT * FROM users WHERE email = $1';
    const result = await pool.query(query, [email]);
    
    if (result.rows.length === 0) {
      console.error('Error: User not found in database');
      return;
    }
    
    const user = result.rows[0];
    console.log('User found:');
    console.log(`ID: ${user.id}`);
    console.log(`Name: ${user.name}`);
    console.log(`Email: ${user.email}`);
    console.log(`Is Admin: ${user.is_admin}`);
    
    // Verify password
    const validPassword = await bcrypt.compare(password, user.password);
    console.log(`Password valid: ${validPassword}`);
    
    if (!validPassword) {
      console.log('Password verification failed. This explains the "invalid credential" error.');
    } else {
      console.log('Password verification successful. Login should work.');
    }
    
    // Close the pool
    await pool.end();
  } catch (error) {
    console.error('Error verifying login:', error);
  }
}

verifyLogin();