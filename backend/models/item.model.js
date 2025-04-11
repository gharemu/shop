const pool = require('../config/db.config');

class Item {
    static async create(itemData) {
        const { name, description, price, category, image_url } = itemData;
        const query = 'INSERT INTO items (name, description, price, category, image_url) VALUES ($1, $2, $3, $4, $5) RETURNING *';
        const result = await pool.query(query, [name, description, price, category, image_url]);
        return result.rows[0];
    }

    static async getAll() {
        const query = 'SELECT * FROM items ORDER BY created_at DESC';
        const result = await pool.query(query);
        return result.rows;
    }

    static async update(id, itemData) {
        const { name, description, price, category, image_url } = itemData;
        const query = 'UPDATE items SET name = $1, description = $2, price = $3, category = $4, image_url = $5 WHERE id = $6 RETURNING *';
        const result = await pool.query(query, [name, description, price, category, image_url, id]);
        return result.rows[0];
    }

    static async delete(id) {
        const query = 'DELETE FROM items WHERE id = $1 RETURNING *';
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }
}

module.exports = Item;