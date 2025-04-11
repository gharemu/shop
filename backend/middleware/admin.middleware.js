const isAdmin = (req, res, next) => {
    if (!req.user.isAdmin) {
        return res.status(403).json({ error: 'Access denied. Admin only.' });
    }
    next();
};

module.exports = isAdmin;