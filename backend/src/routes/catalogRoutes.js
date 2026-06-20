const router = require('express').Router();
const c = require('../controllers/catalogController');

router.get('/products', c.listProducts);
router.get('/products/featured', c.featured);
router.get('/products/:id', c.getProduct);
router.get('/categories', c.listCategories);
router.get('/brands', c.listBrands);
module.exports = router;
