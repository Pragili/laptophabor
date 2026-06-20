const router = require('express').Router();
const c = require('../controllers/reviewController');
const auth = require('../middleware/auth');
router.get('/product/:productId', c.listForProduct);
router.post('/', auth, c.create);
router.put('/:id', auth, c.update);
router.delete('/:id', auth, c.remove);
module.exports = router;
