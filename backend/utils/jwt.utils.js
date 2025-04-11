const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

const generateToken = (userId, isAdmin = false) => {
  return jwt.sign(
    { 
      id: userId,
      isAdmin: isAdmin 
    }, 
    JWT_SECRET, 
    { expiresIn: '24h' }
  );
};

const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    return null;
  }
};

module.exports = { generateToken, verifyToken };