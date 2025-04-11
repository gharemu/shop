const pool = require('../config/db.config');

class User {
    // Update the create method to include is_admin
    static async create(name, email, password, is_admin = false) {
        const query = 'INSERT INTO users (name, email, password, is_admin) VALUES ($1, $2, $3, $4) RETURNING *';
        const result = await pool.query(query, [name, email, password, is_admin]);
        return result.rows[0];
    }

    static async findByEmail(email) {
        const query = 'SELECT * FROM users WHERE email = $1';
        const result = await pool.query(query, [email]);
        return result.rows[0];
    }
    
    static async findById(id) {
        const query = 'SELECT * FROM users WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }
    
    static async update(id, userData) {
        // Build dynamic query based on provided fields
        const fields = Object.keys(userData);
        const values = Object.values(userData);
        
        // If no fields to update, return the current user
        if (fields.length === 0) {
            return this.findById(id);
        }
        
        // Build SET part of query
        const setClause = fields.map((field, index) => `${field} = $${index + 1}`).join(', ');
        
        // Add id as the last parameter
        values.push(id);
        
        const query = `UPDATE users SET ${setClause} WHERE id = $${values.length} RETURNING *`;
        const result = await pool.query(query, values);
        return result.rows[0];
    }
}

module.exports = User;