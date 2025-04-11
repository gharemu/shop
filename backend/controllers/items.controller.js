const Item = require('../models/item.model');

const addItem = async (req, res) => {
    try {
        const item = await Item.create(req.body);
        res.status(201).json({ success: true, item });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getAllItems = async (req, res) => {
    try {
        const items = await Item.getAll();
        res.json({ items });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const updateItem = async (req, res) => {
    try {
        const item = await Item.update(req.params.id, req.body);
        if (!item) {
            return res.status(404).json({ error: 'Item not found' });
        }
        res.json({ success: true, item });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteItem = async (req, res) => {
    try {
        const item = await Item.delete(req.params.id);
        if (!item) {
            return res.status(404).json({ error: 'Item not found' });
        }
        res.json({ success: true, message: 'Item deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = { addItem, getAllItems, updateItem, deleteItem };