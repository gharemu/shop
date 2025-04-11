const router = require('express').Router();
const { addItem, getAllItems, updateItem, deleteItem } = require('../controllers/items.controller');
const authenticateToken = require('../middleware/auth.middleware');
const isAdmin = require('../middleware/admin.middleware');

router.get('/', getAllItems);
router.post('/add', authenticateToken, isAdmin, addItem);
router.put('/update/:id', authenticateToken, isAdmin, updateItem);
router.delete('/delete/:id', authenticateToken, isAdmin, deleteItem);

module.exports = router;