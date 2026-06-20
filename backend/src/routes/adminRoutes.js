const router = require('express').Router();
const c = require('../controllers/adminController');
const auth = require('../middleware/auth');
const requireRole = require('../middleware/role');
const upload = require('../middleware/upload');

router.use(auth, requireRole('admin'));
router.get('/dashboard', c.dashboard);
router.post('/products', upload.array('images', 6), c.createProduct);
router.put('/products/:id', upload.array('images', 6), c.updateProduct);
router.delete('/products/:id', c.deleteProduct);
router.get('/orders', c.listOrders);
router.put('/orders/:id/status', c.updateOrderStatus);
router.get('/users', c.listUsers);
router.put('/users/:id/role', c.setUserRole);
module.exports = router;
