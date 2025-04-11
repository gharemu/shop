const User = require('../models/user.model');
const { hashPassword, comparePassword } = require('../utils/password.utils');
const { generateToken } = require('../utils/jwt.utils');

const register = async (req, res) => {
    try {
        const { name, email, password, isAdmin } = req.body;
        
        const existingUser = await User.findByEmail(email);
        if (existingUser) {
            return res.status(400).json({ error: 'User already exists' });
        }

        const hashedPassword = await hashPassword(password);
        
        // Only allow setting isAdmin if it's explicitly provided
        // In a production app, you might want additional security here
        const is_admin = isAdmin === true;
        
        const user = await User.create(name, email, hashedPassword, is_admin);
        
        res.status(201).json({ success: true, message: 'User registered successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        
        // Debug log (remove in production)
        console.log(`Login attempt: ${email}`);
        
        const user = await User.findByEmail(email);
        if (!user) {
            console.log(`User not found: ${email}`);
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        console.log(`User found: ${user.email}, is_admin: ${user.is_admin}`);
        
        const validPassword = await comparePassword(password, user.password);
        if (!validPassword) {
            console.log(`Invalid password for user: ${email}`);
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = generateToken(user.id, user.is_admin);
        res.json({ 
            success: true,
            token, 
            isAdmin: user.is_admin,
            name: user.name,
            email: user.email
        });
    } catch (error) {
        console.error(`Login error: ${error.message}`);
        res.status(500).json({ error: error.message });
    }
};

module.exports = { register, login };