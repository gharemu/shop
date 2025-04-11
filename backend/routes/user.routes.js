const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authenticateToken = require('../middleware/auth.middleware');

// Get user profile - requires authentication
router.get('/profile', authenticateToken, userController.getUserProfile);

// Update user profile - requires authentication
router.put('/profile/update', authenticateToken, userController.updateUserProfile);

module.exports = router;