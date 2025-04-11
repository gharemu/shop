const bcrypt = require('bcrypt');
const pool = require('../config/db.config');

async function createAdmin() {
  try {
    // Admin credentials
    const name = 'Admin User';
    const email = 'admin@example.com';
    const password = 'admin123';
    
    // Check if admin already exists
    const checkQuery = 'SELECT * FROM users WHERE email = $1';
    const checkResult = await pool.query(checkQuery, [email]);
    
    if (checkResult.rows.length > 0) {
      console.log('Admin user already exists. Updating password and admin status...');
      
      // Hash the password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      
      // Update existing admin - ensure is_admin is TRUE
      const updateQuery = 'UPDATE users SET password = $1, is_admin = TRUE WHERE email = $2 RETURNING *';
      const updateResult = await pool.query(updateQuery, [hashedPassword, email]);
      
      console.log('Admin user updated successfully:');
      console.log(`Name: ${updateResult.rows[0].name}`);
      console.log(`Email: ${email}`);
      console.log(`Is Admin: ${updateResult.rows[0].is_admin}`);
    } else {
      // Hash the password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);
      
      // Insert admin user
      const insertQuery = 'INSERT INTO users (name, email, password, is_admin) VALUES ($1, $2, $3, $4) RETURNING *';
      const insertResult = await pool.query(insertQuery, [name, email, hashedPassword, true]);
      
      console.log('Admin user created successfully:');
      console.log(`Name: ${name}`);
      console.log(`Email: ${email}`);
      console.log(`Is Admin: ${insertResult.rows[0].is_admin}`);
    }
    
    console.log('\nAdmin login credentials:');
    console.log(`Email: ${email}`);
    console.log(`Password: ${password}`);
    
    // Close the pool
    await pool.end();
  } catch (error) {
    console.error('Error creating/updating admin user:', error);
    console.error(error.stack);
  }
}

createAdmin();