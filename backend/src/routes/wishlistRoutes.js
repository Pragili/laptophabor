const router = require('express').Router();
const c = require('../controllers/wishlistController');
const auth = require('../middleware/auth');
router.use(auth);
router.get('/', c.getWishlist);
router.post('/toggle', c.toggle);
module.exports = router;
