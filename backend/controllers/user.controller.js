const User = require('../models/user.model');
const { hashPassword, comparePassword } = require('../utils/password.utils');

const getUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const user = await User.findById(userId);
        
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        // Don't send password in response
        const { password, ...userWithoutPassword } = user;
        
        res.json({ user: userWithoutPassword });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const updateUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, email, currentPassword, newPassword } = req.body;
        
        // Get current user data
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        // If trying to change password, verify current password
        if (currentPassword && newPassword) {
            const validPassword = await comparePassword(currentPassword, user.password);
            if (!validPassword) {
                return res.status(400).json({ error: 'Current password is incorrect' });
            }
            
            // Hash new password
            const hashedPassword = await hashPassword(newPassword);
            req.body.password = hashedPassword;
        }
        
        // Remove currentPassword and newPassword from update data
        delete req.body.currentPassword;
        delete req.body.newPassword;
        
        // Update user
        const updatedUser = await User.update(userId, req.body);
        
        res.json({ message: 'Profile updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = { getUserProfile, updateUserProfile };