const router = require('express').Router();

router.use('/auth', require('./authRoutes'));
router.use('/', require('./catalogRoutes'));
router.use('/cart', require('./cartRoutes'));
router.use('/wishlist', require('./wishlistRoutes'));
router.use('/orders', require('./orderRoutes'));
router.use('/reviews', require('./reviewRoutes'));
router.use('/', require('./miscRoutes'));
router.use('/admin', require('./adminRoutes'));

router.get('/health', (req, res) => res.json({ status: 'ok', time: new Date().toISOString() }));
module.exports = router;
